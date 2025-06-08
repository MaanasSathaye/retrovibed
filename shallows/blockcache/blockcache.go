package blockcache

import (
	"os"
	"path/filepath"
	"strconv"

	"github.com/retrovibed/retrovibed/internal/bytesx"
)

const defaultBlockLength = 32 * bytesx.MiB

func NewDirectoryCache(dir string) (*DirCache, error) {
	if err := os.MkdirAll(dir, 0700); err != nil {
		return nil, err
	}

	return &DirCache{
		root:        dir,
		BlockLength: defaultBlockLength,
	}, nil
}

type DirCache struct {
	root        string
	BlockLength int64
}

func (t DirCache) OpenFile(name string, flag int, perm os.FileMode) (*os.File, error) {
	return nil, nil
}

func (t DirCache) path(off int64) string {
	block := off / int64(t.BlockLength)
	path := filepath.Join(t.root, strconv.FormatInt(block, 10))

	return path
}

func (t DirCache) offset(off int64) (int64, int64) {
	pos := off % t.BlockLength
	max := t.BlockLength - pos

	return pos, max
}

func (t DirCache) ReadAt(p []byte, off int64) (n int, err error) {
	dst, err := os.OpenFile(t.path(off), os.O_RDONLY, 0600)
	if err != nil {
		return 0, err
	}
	defer dst.Close()

	start, _ := t.offset(off)

	return dst.ReadAt(p, start)
}

func (t *DirCache) WriteAt(p []byte, off int64) (n int, err error) {
	path := t.path(off)

	dst, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY, 0600)
	if err != nil {
		return 0, err
	}
	defer dst.Close()

	start, max := t.offset(off)
	if int64(len(p)) > max {
		p = p[:max]
	}

	return dst.WriteAt(p, start)
}
