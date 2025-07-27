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
	"github.com/retrovibed/retrovibed/blockcache"
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

type downloader interface {
	Download(context.Context, string, uint64, uint64, io.Writer) error
}

func NewDeeppoolReaderAt(c *http.Client, md Metadata, l localstorage) *DeeppoolReaderAtCache {
	return &DeeppoolReaderAtCache{md: md, localstorage: l, m: &sync.Mutex{}, d: deeppool.NewRanger(c)}
}

type DeeppoolReaderAtCache struct {
	localstorage
	d  downloader
	md Metadata
	m  *sync.Mutex
}

func (t *DeeppoolReaderAtCache) downloadChunk(prng *rand.ChaCha8, id string, offset uint64, length uint64) error {
	// download a block length at a time.
	doffset := (offset / blockcache.DefaultBlockLength) * blockcache.DefaultBlockLength
	dlength := min(doffset+blockcache.DefaultBlockLength, length) % blockcache.DefaultBlockLength
	if dlength == 0 {
		dlength = blockcache.DefaultBlockLength
	}

	// log.Println("------------------------------ 0 download initiated", id, offset, length, "->", doffset, dlength)
	// defer log.Println("------------------------------ 0 download completed", id, doffset, dlength)

	w, err := cryptox.NewOffsetWriterChaCha20(prng, io.NewOffsetWriter(t.localstorage, int64(doffset)), uint32(doffset))
	if err != nil {
		return err
	}
	ctx, done := context.WithCancel(context.Background())
	defer done()

	return t.d.Download(ctx, id, doffset, doffset+dlength, iox.NewTimeoutWriter(done, 3*time.Second, w))
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

	prng := MetadataChaCha8(t.md)
	if cerr := t.downloadChunk(prng, t.md.ArchiveID, t.md.DiskOffset+uint64(off), t.md.DiskOffset+t.md.Bytes); cerr != nil {
		log.Println("failed to download from archive", cerr)
		return
	}

	// re-read from disk. at this point we either succeeded or failed at resync from the archive.
	return t.localstorage.ReadAt(p, off)
}

func MetadataChaCha8(md Metadata) *rand.ChaCha8 {
	return cryptox.NewChaCha8(uuidx.FirstNonNil(uuid.FromStringOrNil(md.EncryptionSeed), uuid.FromStringOrNil(md.ID)).Bytes())
}
