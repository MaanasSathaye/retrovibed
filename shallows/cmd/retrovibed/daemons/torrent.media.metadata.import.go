package daemons

import (
	"context"
	"io"
	"log"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/tarx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

func MediaMetadataImport(ctx context.Context, db sqlx.Queryer, tvfs fsx.Virtual, tstore storage.ClientImpl) error {
	var (
		latest library.Known
	)

	log.Println("import latest media metadata initiated")
	defer log.Println("import latest media metadata completed")

	if err := library.KnownFindByLastCreated(ctx, db).Scan(&latest); sqlx.IgnoreNoRows(err) != nil {
		return errorsx.Wrap(err, "unable to retrieve latest media metadata")
	}

	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQueryMetadataArchive(),
			tracking.MetadataQueryCreatedAfter(timex.Max(time.UnixMicro(0), latest.CreatedAt.Add(-1*time.Hour))),
		},
	).OrderBy("created_at ASC")

	mdcache := torrent.NewMetadataCache(tvfs.Path())
	iter := sqlx.Scan(tracking.MetadataSearch(ctx, db, q))

	ts := time.Now()

	for _md := range iter.Iter() {
		id := int160.FromBytes(_md.Infohash)

		md, err := mdcache.Read(id)
		if err != nil {
			errorsx.Log(errorsx.Wrap(err, "unable to read torrent metadata"))
			continue
		}
		info, err := md.Metainfo().UnmarshalInfo()
		if err != nil {
			errorsx.Log(errorsx.Wrap(err, "unable to decode torrent info"))
			continue
		}

		disk, err := tstore.OpenTorrent(&info, md.ID)
		if err != nil {
			errorsx.Log(errorsx.Wrap(err, "unable to open torrent reader"))
			continue
		}

		iter, err := tarx.UnpackSeq(io.NewSectionReader(disk, 0, int64(_md.Bytes)))
		if err != nil {
			errorsx.Log(errorsx.Wrap(err, "unable to open read archive"))
			continue
		}

		for header, content := range iter {
			var (
				derr error
				v    library.Known
			)

			log.Println("importing media metadata", id, _md.Description, header.Name)
			d := jsonl.NewDecoder(content)

			for derr = d.Decode(&v); derr == nil; derr = d.Decode(&v) {
				v.AutoDescription = stringsx.Join("\n", v.Title, v.OriginalTitle, v.Overview)
				if err = library.KnownInsertWithDefaults(ctx, db, v).Scan(&v); err != nil {
					return err
				}
			}

			if err := errorsx.Ignore(derr, io.EOF); err != nil {
				return err
			}
		}
	}

	if err := iter.Err(); err != nil {
		return errorsx.Wrap(iter.Err(), "failed to ingest latest media metadata")
	}

	if err := sqlx.Discard(sqlx.Scan(library.MetadataTransferKnownMediaIDFromTorrent(ctx, db, ts))); err != nil {
		return errorsx.Wrap(iter.Err(), "failed to associate known media with upstream library")
	}

	return nil
}
