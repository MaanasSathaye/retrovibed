package library_test

import (
	"context"
	"crypto/md5"
	"io"
	"path/filepath"
	"testing"
	"time"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

type md5archive struct {
	seed   []byte
	result *deeppool.Media
}

func (t *md5archive) Upload(ctx context.Context, mimetype string, r io.Reader) (*deeppool.Media, error) {
	hasher := md5.New()

	decrypt, err := cryptox.NewWriterChaCha20(cryptox.NewChaCha8(t.seed), hasher)
	if err != nil {
		return nil, err
	}
	n, err := io.Copy(decrypt, r)
	if err != nil {
		return nil, err
	}

	t.result = &deeppool.Media{
		Id:        md5x.FormatUUID(hasher),
		Mimetype:  mimetype,
		Bytes:     uint64(n),
		Usage:     uint64(n),
		CreatedAt: time.Now().Format(time.RFC3339),
		UpdatedAt: time.Now().Format(time.RFC3339),
	}

	return t.result, nil
}

func TestArchive(t *testing.T) {
	t.Run("should successfully archive media with valid metadata", func(t *testing.T) {
		var (
			expected = md5.New()
			v        library.Metadata
		)
		ctx, done := testx.Context(t)
		defer done()

		q := sqltestx.Metadatabase(t)
		defer q.Close()

		require.NoError(t, testx.Fake(&v, library.MetadataOptionTestDefaults, func(md *library.Metadata) {
			md.Bytes = 16 * bytesx.KiB
		}))
		require.NoError(t, library.MetadataInsertWithDefaults(ctx, q, v).Scan(&v))

		root := fsx.DirVirtual(filepath.Join(t.TempDir()))

		bcache, err := blockcache.NewDirectoryCache(root.Path(v.ID))
		require.NoError(t, err)

		n, err := io.Copy(
			io.NewOffsetWriter(bcache, 0),
			io.TeeReader(
				io.LimitReader(cryptox.NewChaCha8(v.ID), int64(v.Bytes)),
				expected,
			),
		)
		require.NoError(t, err)
		require.Equal(t, v.Bytes, uint64(n))

		archiver := &md5archive{
			seed: uuidx.FirstNonNil(uuid.FromStringOrNil(v.EncryptionSeed), uuid.FromStringOrNil(v.ID)).Bytes(),
		}

		require.NoError(t, library.Archive(ctx, q, v, root, archiver))
		assert.Equal(t, md5x.FormatUUID(expected), archiver.result.Id)
		assert.Equal(t, v.Bytes, archiver.result.Bytes)
		assert.Equal(t, v.Mimetype, archiver.result.Mimetype)
	})
}
