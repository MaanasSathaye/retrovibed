package blockcache

import (
	"os"
	"path/filepath"
	"strconv"

	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/langx"
)

const defaultBlockLength = 32 * bytesx.MiB

type OptionDirCache func(*DirCache)

func OptionDirCacheBlockLength(n int64) OptionDirCache {
	return func(dc *DirCache) {
		dc.BlockLength = n
	}
}

func NewDirectoryCache(dir string, options ...OptionDirCache) (*DirCache, error) {
	// dir, err := filepath.EvalSymlinks(dir)
	// if err != nil {
	// 	return nil, errorsx.Wrap(err, "symlink resolution failed")
	// }

	if err := os.MkdirAll(dir, 0700); err != nil {
		return nil, errorsx.Wrap(err, "unable to ensure directory exists")
	}

	c := langx.Clone(DirCache{
		root:        dir,
		BlockLength: defaultBlockLength,
	}, options...)
	return &c, nil
}

type DirCache struct {
	root        string
	BlockLength int64
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
	// defer func() {
	// 	log.Println("finished read", n)
	// }()
	readchunk := func(p []byte, off int64) (n int, err error) {
		dst, err := os.Open(t.path(off))
		if err != nil {
			return 0, err
		}
		defer dst.Close()

		start, max := t.offset(off)
		if int64(len(p)) > max {
			p = p[:max]
		}

		return dst.ReadAt(p, start)
	}

	for n < len(p) {
		_n, _err := readchunk(p[n:], off+int64(n))
		if _err != nil {
			return n + _n, _err
		}

		// if np := t.path(off + int64(n)); np != path {
		// 	log.Println("reading", np)
		// 	path = np
		// }
		n += _n
	}

	return n, nil
}

func (t *DirCache) WriteAt(p []byte, off int64) (n int, err error) {
	writechunk := func(p []byte, ioff int64) (n int, err error) {
		path := t.path(ioff)

		dst, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY, 0600)
		if err != nil {
			return 0, err
		}
		defer dst.Close()

		start, max := t.offset(ioff)
		if int64(len(p)) > max {
			p = p[:max]
		}

		return dst.WriteAt(p, start)
	}

	for n < len(p) {
		_n, _err := writechunk(p[n:], off+int64(n))
		if _err != nil {
			return n + _n, _err
		}
		n += _n
	}

	return n, nil
}
