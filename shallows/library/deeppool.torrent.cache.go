package library

import (
	"context"
	"errors"
	"io"
	"io/fs"
	"log"
	"math/rand/v2"
	"net/http"
	"sync"
	"sync/atomic"
	"time"

	"github.com/gofrs/uuid/v5"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/iox"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
)

func NewTorrentStorage(c *http.Client, q sqlx.Queryer, d storage.ClientImpl) *TorrentCacheStorage {
	return &TorrentCacheStorage{
		d:  d,
		q:  q,
		dl: deeppool.NewRanger(c),
		m:  &sync.Mutex{},
	}
}

type TorrentCacheStorage struct {
	d  storage.ClientImpl
	q  sqlx.Queryer
	dl downloader
	m  *sync.Mutex
}

func (t *TorrentCacheStorage) OpenTorrent(info *metainfo.Info, id metainfo.Hash) (storage.TorrentImpl, error) {
	impl, err := t.d.OpenTorrent(info, id)
	if err != nil {
		return nil, err
	}

	return &fallback{
		id:          id,
		TorrentImpl: impl,
		q:           t.q,
		dl:          t.dl,
		m:           t.m,
	}, nil
}

func (t *TorrentCacheStorage) Close() error {
	return t.d.Close()
}

type fallback struct {
	dl downloader
	storage.TorrentImpl
	id           metainfo.Hash
	q            sqlx.Queryer
	m            *sync.Mutex
	cacheblocked atomic.Bool
}

func (t *fallback) downloadChunk(prng *rand.ChaCha8, id string, offset uint64, length uint64) error {
	// download a block length at a time.
	doffset := (offset / blockcache.DefaultBlockLength) * blockcache.DefaultBlockLength
	dlength := min(doffset+blockcache.DefaultBlockLength, length) % blockcache.DefaultBlockLength
	if dlength == 0 {
		dlength = blockcache.DefaultBlockLength
	}

	// log.Println("------------------------------ 1 download initiated", id, offset, length, "->", doffset, dlength)
	// defer log.Println("------------------------------ 1 download completed", id, doffset, dlength)

	w, err := cryptox.NewOffsetWriterChaCha20(prng, io.NewOffsetWriter(t.TorrentImpl, int64(doffset)), uint32(doffset))
	if err != nil {
		return err
	}
	ctx, done := context.WithCancel(context.Background())
	defer done()

	return t.dl.Download(ctx, id, doffset, doffset+dlength, iox.NewTimeoutWriter(done, 3*time.Second, w))
}

func (t *fallback) ReadAt(p []byte, off int64) (n int, err error) {
	if n, err = t.TorrentImpl.ReadAt(p, off); err == nil {
		return n, err
	} else if errorsx.Ignore(err, fs.ErrNotExist) != nil {
		return n, err
	}

	t.m.Lock()
	defer t.m.Unlock()

	if n, err = t.TorrentImpl.ReadAt(p, off); err == nil {
		return n, err
	}

	if t.cacheblocked.Load() {
		return n, errorsx.NewUnrecoverable(errorsx.String("cache layer blocked due to previous error"))
	}

	ctx, done := context.WithTimeout(context.Background(), 3*time.Second)
	defer done()
	q := sqlx.Scan(MetadataForTorrentArchiveRetrieval(ctx, t.q, t.id.Bytes(), uint64(off), uint64(len(p))))
	for v := range q.Iter() {
		switch v.ArchiveID {
		case uuid.Nil.String():
			fallthrough
		case uuid.Max.String():
			continue
		default:
			// non min/max uuid.
		}

		prng := cryptox.NewChaCha8(uuidx.FirstNonNil(uuid.FromStringOrNil(v.EncryptionSeed), uuid.FromStringOrNil(v.ID)).Bytes())
		if cerr := t.downloadChunk(prng, v.ArchiveID, v.DiskOffset, v.Bytes); cerr != nil {
			var (
				unrecoverable errorsx.Unrecoverable
			)

			if errors.As(cerr, &unrecoverable) {
				// TODO update database to prevent attempts in the future
				t.cacheblocked.Store(true)
			}

			log.Println("failed to download from archive", cerr)
			return n, cerr
		}
	}

	if qerr := q.Err(); qerr != nil {
		return n, err
	}

	// re-read from disk. at this point we either succeeded or failed at resync from the archive.
	return t.TorrentImpl.ReadAt(p, off)
}

func (t *fallback) Close() error {
	return t.TorrentImpl.Close()
}
