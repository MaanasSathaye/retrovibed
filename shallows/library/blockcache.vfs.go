package library

import (
	"context"
	"io/fs"
	"log"
	"time"

	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/internal/fsx"
)

func New(v fsx.Virtual, lookup func(ctx context.Context, s string) (md *Metadata, err error)) fs.FS {
	return vstoragefs{Virtual: v, metadata: lookup}
}

type vstoragefs struct {
	fsx.Virtual
	metadata func(ctx context.Context, s string) (md *Metadata, err error)
}

func (t vstoragefs) Open(name string) (fs.File, error) {
	ctx, done := context.WithTimeout(context.Background(), time.Second)
	defer done()

	md, err := t.metadata(ctx, name)
	if err != nil {
		return nil, err
	}
	log.Println("opening", name, "as", t.Virtual.Path(md.ID), md.DiskOffset, md.Bytes)

	dcache, err := blockcache.NewDirectoryCache(t.Virtual.Path(md.ID))
	if err != nil {
		return nil, err
	}

	return blockcache.NewFile(dcache, md.CreatedAt, md.ID, md.Bytes, 0600, blockcache.WithInitialOffset(md.DiskOffset)), nil
}
