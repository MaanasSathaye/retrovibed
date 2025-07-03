package library

import (
	"context"
	"io"
	"io/fs"
	"log"
	"math/rand/v2"
	"net/http"
	"sync"
	"time"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/iox"
	"github.com/retrovibed/retrovibed/internal/uuidx"
)

type localstorage interface {
	io.ReaderAt
	io.WriterAt
}

func NewDeeppoolReaderAt(c *http.Client, md Metadata, l localstorage) *DeeppoolReaderAtCache {
	return &DeeppoolReaderAtCache{c: c, md: md, localstorage: l, m: &sync.Mutex{}}
}

type DeeppoolReaderAtCache struct {
	localstorage
	c  *http.Client
	md Metadata
	m  *sync.Mutex
}

func (t *DeeppoolReaderAtCache) downloadChunk(prng *rand.ChaCha8, id string, offset uint64, length uint64) error {
	log.Println("download initiated", id, offset, length)
	defer log.Println("download completed", id, offset, length)
	w, err := cryptox.NewWriterChaCha20(prng, io.NewOffsetWriter(t.localstorage, int64(offset)))
	if err != nil {
		return err
	}
	ctx, done := context.WithCancel(context.Background())
	defer done()

	return deeppool.NewRetrieval(t.c).Download(ctx, id, iox.NewTimeoutWriter(done, 3*time.Second, w))
	// TODO simplify this down to being able to read random blocks.
	// w, err := cryptox.NewOffsetWriterChaCha20(prng, t.TorrentImpl, uint32(offset))
	// if err != nil {
	// 	return err
	// }
	// return deeppool.NewRanger(t.c).Download(ctx, id, offset, length, w)
}

func (t *DeeppoolReaderAtCache) ReadAt(p []byte, off int64) (n int, err error) {
	if n, err = t.localstorage.ReadAt(p, off); err == nil {
		return n, err
	} else if errorsx.Ignore(err, fs.ErrNotExist) != nil {
		return n, err
	}

	t.m.Lock()
	defer t.m.Unlock()

	if n, err = t.localstorage.ReadAt(p, off); err == nil {
		return n, err
	}

	prng := cryptox.NewChaCha8(uuidx.FirstNonZero(uuid.FromStringOrNil(t.md.EncryptionSeed), uuid.FromStringOrNil(t.md.ID)).Bytes())
	if cerr := t.downloadChunk(prng, t.md.ArchiveID, t.md.DiskOffset, t.md.Bytes); cerr != nil {
		log.Println("failed to download from archive", cerr)
		return
	}

	// re-read from disk. at this point we either succeeded or failed at resync from the archive.
	return t.localstorage.ReadAt(p, off)
}
