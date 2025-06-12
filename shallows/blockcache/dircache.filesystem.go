package blockcache

import (
	"io"
	"io/fs"
	"log"
	"path/filepath"
	"sync/atomic"
	"time"

	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/internal/slicesx"
)

type Info struct {
	*File
}

// IsDir implements fs.FileInfo.
func (t Info) IsDir() bool {
	return t.dir
}

// ModTime implements fs.FileInfo.
func (t Info) ModTime() time.Time {
	return t.ts
}

// Mode implements fs.FileInfo.
func (t Info) Mode() fs.FileMode {
	if t.dir {
		return fs.ModeDir | (0700 & fs.ModePerm)
	}

	return (0600 & fs.ModePerm)
}

// Name implements fs.FileInfo.
func (t Info) Name() string {
	return filepath.Base(t.Path)
}

// Size implements fs.FileInfo.
func (t Info) Size() int64 {
	return int64(t.Length)
}

// Sys implements fs.FileInfo.
func (t Info) Sys() any {
	return nil
}

type Dir struct {
	*File
	index int
	ent   []*File
}

// ReadDir reads the contents of the directory and returns
// a slice of up to n DirEntry values in directory order.
// Subsequent calls on the same file will yield further DirEntry values.
//
// If n > 0, ReadDir returns at most n DirEntry structures.
// In this case, if ReadDir returns an empty slice, it will return
// a non-nil error explaining why.
// At the end of a directory, the error is io.EOF.
// (ReadDir must return io.EOF itself, not an error wrapping io.EOF.)
//
// If n <= 0, ReadDir returns all the DirEntry values from the directory
// in a single slice. In this case, if ReadDir succeeds (reads all the way
// to the end of the directory), it returns the slice and a nil error.
// If it encounters an error before the end of the directory,
// ReadDir returns the DirEntry list read until that point and a non-nil error.
func (t Dir) ReadDir(n int) (z []fs.DirEntry, err error) {
	if n <= 0 {
		ents := slicesx.MapTransform(func(fn *File) fs.DirEntry {
			return fn
		}, t.ent...)
		return ents, nil
	}

	if len(t.ent) == 0 {
		return nil, io.EOF
	}

	m := min(len(t.ent)-t.index, n)
	if m == 0 {
		return nil, io.EOF
	}

	return slicesx.MapTransform(func(fn *File) fs.DirEntry {
		return fn
	}, t.ent[t.index:m]...), nil
}

type File struct {
	cache  *DirCache
	Path   string
	Offset uint64
	Length uint64
	dir    bool
	index  uint64
	ts     time.Time
}

// Info implements fs.DirEntry.
func (t *File) Info() (fs.FileInfo, error) {
	return Info{File: t}, nil
}

// IsDir implements fs.DirEntry.
func (t *File) IsDir() bool {
	return t.dir
}

// Name implements fs.DirEntry.
func (t *File) Name() string {
	return Info{File: t}.Name()
}

// Type implements fs.DirEntry.
func (t *File) Type() fs.FileMode {
	return Info{File: t}.Mode() & fs.ModeType
}

// Close implements fs.File.
func (t *File) Close() error {
	return nil
}

// Read implements fs.File.
func (t *File) Read(p []byte) (int, error) {
	n, err := t.ReadAt(p, int64(t.index))
	atomic.AddUint64(&t.index, uint64(n))
	return n, err
}

// Stat implements fs.File.
func (t *File) Stat() (fs.FileInfo, error) {
	return Info{File: t}, nil
}

func (t *File) ReadAt(p []byte, offset int64) (int, error) {
	return t.cache.ReadAt(p, offset)
}

type FS struct {
	dirent []*File
	mapped map[string]*File
	cache  *DirCache
}

// Open implements fs.StatFS.
func (t FS) Open(name string) (fs.File, error) {
	if f, ok := t.mapped[name]; ok {
		dup := *f
		return &dup, nil
	}

	if filepath.Base(t.cache.root) == name {
		return Dir{
			ent: t.dirent,
			File: &File{
				cache: t.cache,
				Path:  name,
				dir:   true,
			},
		}, nil
	}

	return nil, fs.ErrNotExist
}

// Stat implements fs.StatFS.
func (t FS) Stat(name string) (fs.FileInfo, error) {
	if filepath.Base(t.cache.root) == name {
		return Info{File: &File{
			cache: t.cache,
			Path:  name,
			dir:   true,
		}}, nil
	}

	if f, ok := t.mapped[name]; ok {
		return Info{File: f}, nil
	}

	return nil, fs.ErrNotExist
}

func TorrentFilesystem(d *DirCache, info *metainfo.Info) FS {
	prefix := filepath.Base(d.root)
	contents := make([]*File, 0, max(len(info.Files), 1))
	for fn := range metainfo.Files(info) {
		contents = append(contents, &File{
			cache:  d,
			Path:   filepath.Join(prefix, fn.Path),
			Offset: fn.Offset,
			Length: fn.Length,
			ts:     time.Now(),
		})
	}
	return NewFS(d, contents...)
}

func NewFS(d *DirCache, fns ...*File) FS {
	contents := make(map[string]*File, max(len(fns), 1))
	for _, fn := range fns {
		contents[fn.Path] = fn

		for _, d := range filepath.SplitList(filepath.Dir(fn.Path)) {
			log.Println("dirs", d)
		}
	}
	return FS{cache: d, mapped: contents, dirent: fns}
}
