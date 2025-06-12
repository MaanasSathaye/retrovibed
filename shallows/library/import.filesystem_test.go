package library_test

import (
	"io/fs"
	"os"
	"path/filepath"
	"testing"

	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/stretchr/testify/require"
)

func TestImportFilesystemDryRun(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()

	count := 0
	for _, err := range library.ImportFilesystem(ctx, library.ImportFileDryRun, os.DirFS(testx.Fixture()).(fs.StatFS), "tree.example.1") {
		require.NoError(t, err)
		count++
	}

	require.Equal(t, 2, count)
}

func TestImportFilesystemCopy(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()

	tmpdir := t.TempDir()
	vfs := fsx.DirVirtual(tmpdir)
	count := 0
	for tx, err := range library.ImportFilesystem(ctx, library.ImportCopyFile(vfs), os.DirFS(testx.Fixture()).(fs.StatFS), "tree.example.1") {
		require.NoError(t, err)
		require.Equal(t, testx.ReadMD5(testx.Fixture(tx.Path)), testx.ReadMD5(filepath.Join(tmpdir, md5x.FormatUUID(tx.MD5))))
		count++
	}

	require.Equal(t, 2, count)
}

func TestImportFilesystemSymlink(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()

	tmpdir := t.TempDir()
	vfs := fsx.DirVirtual(tmpdir)
	fixvfs := fsx.DirVirtual(testx.Must(filepath.Abs(testx.Fixture()))(t))
	count := 0

	for tx, err := range library.ImportFilesystem(ctx, library.ImportSymlinkFile(fixvfs, vfs), os.DirFS(testx.Fixture()).(fs.StatFS), "tree.example.1") {
		require.NoError(t, err)
		require.Equal(t, testx.ReadMD5(testx.Fixture(tx.Path)), testx.ReadMD5(filepath.Join(tmpdir, md5x.FormatUUID(tx.MD5))))
		count++
	}

	require.Equal(t, 2, count)
}
