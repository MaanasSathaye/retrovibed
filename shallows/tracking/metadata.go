package tracking

import (
	"context"
	"crypto/md5"
	"encoding/hex"
	"io"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/anacrolix/missinggo/pubsub"
	"github.com/davecgh/go-spew/spew"
	"github.com/gofrs/uuid/v5"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/library"
	"golang.org/x/exp/constraints"
	"golang.org/x/time/rate"
)

func MetadataOptionNoop(*Metadata) {}

func MetadataOptionInitiate(md *Metadata) {
	md.InitiatedAt = time.Now()
}

func MetadataOptionFromInfo(i *metainfo.Info) func(*Metadata) {
	return func(m *Metadata) {
		m.Description = strings.ToValidUTF8(i.Name, "\uFFFD")
		m.Bytes = uint64(i.TotalLength())
		m.Private = langx.Autoderef(i.Private)
	}
}

func MetadataOptionDescription(d string) func(*Metadata) {
	return func(m *Metadata) {
		m.Description = d
	}
}

// Currently will select just the first tracker due to poor list support in duckdb.
func MetadataOptionTrackers(d ...string) func(*Metadata) {
	return func(m *Metadata) {
		m.Tracker = slicesx.FirstOrZero(d...)
	}
}

func MetadataOptionKnownMediaID(d string) func(*Metadata) {
	return func(m *Metadata) {
		m.KnownMediaID = d
	}
}

func MetadataOptionEntropySeed(d ...[]byte) func(*Metadata) {
	return func(m *Metadata) {
		m.EncryptionSeed = md5x.FormatUUID(md5x.Digest(d...))
	}
}

func MetadataOptionAutoArchive(b bool) func(*Metadata) {
	return func(m *Metadata) {
		m.Archivable = b
	}
}

func MetadataOptionBytes[T constraints.Integer](b T) func(*Metadata) {
	return func(m *Metadata) {
		m.Bytes = uint64(b)
	}
}

func MetadataOptionDownloaded[T constraints.Integer](b T) func(*Metadata) {
	return func(m *Metadata) {
		m.Downloaded = uint64(b)
	}
}

func MetadataOptionTestDefaults(m *Metadata) {
	*m = NewMetadata(
		langx.Autoptr(metainfo.NewHashFromBytes(int160.Random().Bytes())),
	)
}

func MetadataOptionJSONSafeEncode(m *Metadata) {
	m.CreatedAt = timex.RFC3339NanoEncode(m.CreatedAt)
	m.UpdatedAt = timex.RFC3339NanoEncode(m.UpdatedAt)
}

func MetadataOptionAutoDescription(m *Metadata) {
	m.AutoDescription = NormalizedDescription(m.Description)
}

func NewMetadata(md *metainfo.Hash, options ...func(*Metadata)) (m Metadata) {
	r := langx.Clone(Metadata{
		ID:             HashUID(md),
		Infohash:       md.Bytes(),
		InitiatedAt:    timex.Inf(),
		NextAnnounceAt: timex.Inf(),
		KnownMediaID:   uuid.Max.String(),
		EncryptionSeed: uuid.Must(uuid.NewV4()).String(),
	}, options...)
	return r
}

func MetadataQueryNotInitiated() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.initiated_at = 'infinity'")
}

func MetadataQueryInitiated() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.initiated_at < NOW()")
}

func MetadataQueryIncomplete() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.downloaded < torrents_metadata.bytes")
}

func MetadataQueryNotPaused() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.paused_at = 'infinity'")
}

func MetadataQueryNeedsVerification() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.verify_at < NOW()")
}

func MetadataQuerySeeding() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.seeding")
}

func MetadataQueryHasTracker() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.tracker != ''")
}

func MetadataQueryNeedsAnnounce() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.next_announce_at < NOW()")
}

func MetadataQueryAnnounceable() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.next_announce_at < 'infinity'")
}

func MetadataQueryNeedsKnownMediaID() squirrel.Sqlizer {
	return squirrel.Expr("torrents_metadata.known_media_id = 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'")
}

func MetadataSearch(ctx context.Context, q sqlx.Queryer, b squirrel.SelectBuilder) MetadataScanner {
	return NewMetadataScannerStatic(b.RunWith(q).QueryContext(ctx))
}

func MetadataQuerySearch(q string, columns ...string) squirrel.Sqlizer {
	return duckdbx.FTSSearch("fts_main_torrents_metadata", q, columns...)
}

func MetadataSearchBuilder() squirrel.SelectBuilder {
	return squirrelx.PSQL.Select(sqlx.Columns(MetadataScannerStaticColumns)...).From("torrents_metadata")
}

func Verify(ctx context.Context, t torrent.Torrent) error {
	log.Println("verify initiated", t.Metadata().DisplayName)
	defer log.Println("verify completed", t.Metadata().DisplayName, spew.Sdump(t.Stats()))
	return torrent.Verify(ctx, t)
}

func DownloadInto(ctx context.Context, q sqlx.Queryer, vfs fsx.Virtual, md *Metadata, t torrent.Torrent, dst io.Writer) (err error) {
	var (
		downloaded int64
	)

	pctx, done := context.WithCancel(ctx)
	defer done()

	// update the progress.
	go DownloadProgress(pctx, q, md, t)

	mediavfs := fsx.DirVirtual(vfs.Path("media"))
	torrentvfs := fsx.DirVirtual(vfs.Path("torrent"))
	bcache, err := blockcache.NewDirectoryCache(torrentvfs.Path(int160.FromBytes(md.Infohash).String()))
	if err != nil {
		return err
	}

	// just copying as we receive data to block until done.
	if downloaded, err = torrent.DownloadInto(ctx, dst, t, torrent.TuneAnnounceUntilComplete, torrent.TuneNewConns); err != nil {
		return errorsx.Wrap(err, "download failed")
	}

	log.Println("content transfer to library initiated", t.Metadata().ID.String())
	defer log.Println("content transfer to library completed", t.Metadata().ID.String())

	for tx, cause := range library.ImportFilesystem(ctx, ImportSymlink(int160.FromByteArray(t.Metadata().ID), torrentvfs, mediavfs), blockcache.TorrentFilesystem(bcache, t.Info()), ".") {
		if cause != nil {
			log.Println("import failed", cause)
			err = errorsx.Compact(err, cause)
			continue
		}

		if uint64(downloaded) != tx.Bytes {
			err = errorsx.Compact(err, errorsx.Errorf("import failed did not read all data %d != %d", tx.Bytes, downloaded))
			continue
		}

		desc := DescriptionFromPath(md, tx.Path)
		lmd := library.NewMetadata(
			md5x.FormatUUID(tx.MD5),
			library.MetadataOptionDescription(desc),
			library.MetadataOptionAutoDescription(NormalizedDescription(desc)),
			library.MetadataOptionBytes(tx.Bytes),
			library.MetadataOptionOffset(tx.Offset),
			library.MetadataOptionTorrentID(md.ID),
			library.MetadataOptionKnownMediaID(md.KnownMediaID),
			library.MetadataOptionMimetype(tx.Mimetype.String()),
			library.MetadataOptionEncryptionSeed(md.EncryptionSeed),
			library.MetadataOptionArchivable(md.Archivable),
		)

		if err := library.MetadataInsertWithDefaults(ctx, q, lmd).Scan(&lmd); err != nil {
			return errorsx.Wrap(err, "unable to record library metadata")
		}

		log.Println("new library content", lmd.ID, lmd.Description)
	}

	if err != nil {
		return errorsx.Wrap(err, "failed to transfer files into library")
	}

	stats := t.Stats()
	log.Println("download completed", md.ID, downloaded)
	if err := MetadataCompleteByID(ctx, q, md.ID, 0, uint64(downloaded), stats.BytesWrittenData.Uint64()).Scan(md); err != nil {
		return errorsx.Wrap(err, "progress update failed")
	}

	return nil
}

func Download(ctx context.Context, q sqlx.Queryer, vfs fsx.Virtual, md *Metadata, t torrent.Torrent) (err error) {
	var (
		mhash = md5.New()
	)
	return DownloadInto(ctx, q, vfs, md, t, mhash)
}

func DescriptionFromPath(md *Metadata, path string) string {
	tmp := filepath.Base(path)
	if hex.EncodeToString(md.Infohash) == tmp {
		tmp = ""
	}

	return NormalizedDescription(stringsx.FirstNonBlank(tmp, md.Description))
}

func DownloadProgress(ctx context.Context, q sqlx.Queryer, md *Metadata, dl torrent.Torrent) {
	var (
		statsfreq = envx.Duration(1*time.Minute, env.TorrentDownloadStats)
		sub       pubsub.Subscription
	)

	log.Println("monitoring download progress initiated", md.ID, md.Description, md.Tracker, statsfreq)
	defer log.Println("monitoring download progress completed", md.ID, md.Description, md.Tracker)
	// Revisit once resume is working.
	if err := dl.Tune(torrent.TuneSubscribe(&sub)); err != nil {
		log.Println("unable to subscribe", err)
		return
	}
	defer sub.Close()

	statst := time.NewTicker(statsfreq)
	l := rate.NewLimiter(rate.Every(time.Second), 1)
	for {
		select {
		case <-statst.C:
			stats := dl.Stats()
			info := dl.Info()

			log.Printf(
				"%s - %s: info(%t) seeding(%t), peers(%d:%d:%d) pieces(m%d:o%d:u%d:c%d - f%d)\n", md.ID, hex.EncodeToString(md.Infohash), info != nil, stats.Seeding, stats.ActivePeers, stats.PendingPeers, stats.TotalPeers,
				stats.Missing, stats.Outstanding, stats.Unverified, stats.Completed, stats.Failed,
			)

			if err := dl.Tune(torrent.TuneNewConns); err != nil {
				log.Println("unable to request new connections", err)
				continue
			}

			current := uint64(dl.BytesCompleted())
			if md.Downloaded == current {
				continue
			}

			uctx, done := context.WithTimeout(context.Background(), time.Second)
			if err := MetadataProgressByID(uctx, q, md.ID, uint16(stats.ActivePeers), current).Scan(md); err != nil {
				done()
				log.Println("failed to update progress", err)
			}
			done()
		case <-sub.Values:
			if !l.Allow() {
				continue
			}

			current := uint64(dl.BytesCompleted())
			if md.Downloaded == current {
				continue
			}

			statst.Reset(statsfreq)
			stats := dl.Stats()

			log.Printf(
				"%s - %s: info(%t) seeding(%t), peers(a%d:h%d:p%d:t%d) pieces(m%d:o%d:u%d:c%d - f%d)\n", md.ID, hex.EncodeToString(md.Infohash), true, stats.Seeding, stats.ActivePeers, stats.HalfOpenPeers, stats.PendingPeers, stats.TotalPeers,
				stats.Missing, stats.Outstanding, stats.Unverified, stats.Completed, stats.Failed,
			)

			if err := MetadataProgressByID(ctx, q, md.ID, uint16(stats.ActivePeers), current).Scan(md); err != nil {
				log.Println("failed to update progress", err)
			}
		case <-ctx.Done():
			return
		}
	}
}

func ImportSymlink(id int160.T, srcvfs, vfs fsx.Virtual) library.ImportOp {
	critical := &sync.Mutex{}
	return func(ctx context.Context, root fs.StatFS, path string) (*library.Transfered, error) {
		tx, err := library.TransferedFromPath(root, path)
		if err != nil {
			return nil, err
		}

		src, err := root.Open(path)
		if err != nil {
			return nil, err
		}
		defer src.Close()

		if n, err := io.Copy(tx.MD5, src); err != nil {
			return nil, err
		} else {
			tx.Bytes = uint64(n)
		}

		if n, ok := src.(*blockcache.File); ok {
			tx.Offset = n.Offset
		}

		uid := md5x.FormatUUID(tx.MD5)

		critical.Lock()
		defer critical.Unlock()
		if err := os.Remove(vfs.Path(uid)); fsx.IgnoreIsNotExist(err) != nil {
			return nil, errorsx.Wrap(err, "unable to ensure symlink destination is available")
		}

		if err := os.Symlink(srcvfs.Path(id.String()), vfs.Path(uid)); err != nil {
			return nil, errorsx.Wrapf(err, "unable to symlink to original location: %s -> %s", srcvfs.Path(id.String()), vfs.Path(uid))
		}

		log.Printf("symlinked: %s -> %s\n", srcvfs.Path(id.String()), vfs.Path(uid))

		return tx, nil
	}
}
