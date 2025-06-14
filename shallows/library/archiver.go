package library

import (
	"context"
	"io"
	"log"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
)

type archiver interface {
	Upload(ctx context.Context, mimetype string, r io.Reader) (m *deeppool.Media, _ error)
}

func Archive(ctx context.Context, q sqlx.Queryer, md Metadata, vfs fsx.Virtual, dst archiver) error {
	seed := cryptox.NewChaCha8(uuidx.FirstNonZero(uuid.FromStringOrNil(md.EncryptionSeed), uuid.FromStringOrNil(md.ID)).Bytes())

	cache, err := blockcache.NewDirectoryCache(vfs.Path(md.ID))
	if err != nil {
		return errorsx.Wrapf(err, "unable to create reader: %s", md.ID)
	}

	src, err := cryptox.NewReaderChaCha20(seed, io.NewSectionReader(cache, int64(md.DiskOffset), int64(md.Bytes)))
	if err != nil {
		return err
	}

	uploaded, err := dst.Upload(ctx, md.Mimetype, io.LimitReader(src, int64(md.Bytes)))
	if err != nil {
		return err
	}
	log.Println("archive completed", md.ID)
	return MetadataArchivedByID(ctx, q, md.ID, uploaded.Id, uploaded.Usage).Scan(&md)
}
