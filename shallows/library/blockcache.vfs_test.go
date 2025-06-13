package library_test

import (
	"context"
	"crypto/md5"
	"io"
	"io/fs"
	"os"
	"strings"
	"testing"

	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/stretchr/testify/require"
)

func TestVStorageFS(t *testing.T) {
	t.Run("Open method", func(t *testing.T) {
		t.Run("read data from storage", func(t *testing.T) {
			ctx, done := testx.Context(t)
			defer done()
			db := sqltestx.Metadatabase(t)
			var (
				md       library.Metadata
				expected = md5.New()
			)

			storage := fsx.DirVirtual(t.TempDir())
			require.NoError(t, testx.Fake(&md, library.MetadataOptionTestDefaults))
			require.NoError(t, library.MetadataInsertWithDefaults(ctx, db, md).Scan(&md))
			require.NoError(t, os.WriteFile(storage.Path(md.ID), testx.IOBytes(io.TeeReader(cryptox.NewChaCha8(t.Name()), expected)), 0600))

			fsys := library.New(storage, func(ctx context.Context, s string) (*library.Metadata, error) {
				var (
					md library.Metadata
				)
				return &md, library.MetadataFindByID(ctx, db, strings.TrimPrefix(s, "m/")).Scan(&md)
			})

			file, err := fsys.Open(md.ID)
			require.NoError(t, err, "Open should not return an error on success")
			require.NotNil(t, file, "Open should return a non-nil fs.File on success")

			// Verify the returned file's properties via its Stat() method
			fileInfo, err := file.Stat()
			require.NoError(t, err, "Stat() on opened file should not return an error")
			require.NotNil(t, fileInfo, "Stat() should return non-nil FileInfo")

			require.Equal(t, md.ID, fileInfo.Name())
			require.EqualValues(t, md.Bytes, fileInfo.Size())
			require.Equal(t, md.CreatedAt, fileInfo.ModTime())
			require.Equal(t, fs.FileMode(0600), fileInfo.Mode(), "File.Mode should be 0600 for regular file")
			require.False(t, fileInfo.IsDir(), "File.IsDir should be false for a regular file")
			require.Nil(t, fileInfo.Sys(), "File.Sys should be nil")

			// ensure we can read the data
			require.Equal(t, md5x.FormatUUID(expected), testx.IOMD5(file))

			// Ensure the file can be closed
			require.NoError(t, file.Close(), "File.Close should not return an error")
		})
	})
}
