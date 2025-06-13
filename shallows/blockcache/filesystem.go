package blockcache

import (
	"fmt"
	"io"
	"io/fs"
	"log"
	"path/filepath"
	"strings"
	"sync/atomic"
	"time"

	"github.com/porfirion/trie"

	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
)

type Info struct {
	*File
}

func (t Info) ModTime() time.Time {
	log.Println("Info.ModTime", t.ts)
	return t.ts
}

func (t Info) Mode() fs.FileMode {
	log.Println("Info.Mode", t.m)
	return t.m
}

func (t Info) Size() int64 {
	log.Println("Info.Size", t.Length)
	return int64(t.Length)
}

func (t Info) Sys() any {
	log.Println("Info.Sys")
	return nil
}

// FileOption defines the signature for functional options to NewFile.
type FileOption func(*File)

// WithInitialOffset sets the initial Offset field of the File.
func WithInitialOffset(val uint64) FileOption {
	return func(f *File) {
		f.Offset = val
	}
}

// WithInitialIndex sets the initial value of the atomic index field.
func WithInitialIndex(val uint64) FileOption {
	return func(f *File) {
		f.index.Store(val)
	}
}

// NewFile function updated to use the option pattern.
func NewFile(dca cache, ts time.Time, path string, len uint64, mod fs.FileMode, opts ...FileOption) *File {
	return langx.Autoptr(langx.Clone(File{
		cache:  dca,
		Path:   path,
		Length: len,
		ts:     ts,
		m:      mod,
		index:  new(atomic.Uint64),
	}, opts...))
}

type File struct {
	cache  cache
	Path   string
	Offset uint64
	Length uint64
	m      fs.FileMode
	index  *atomic.Uint64
	ts     time.Time
}

func (t *File) Info() (fs.FileInfo, error) {
	return Info{File: t}, nil
}

func (t *File) IsDir() bool {
	return t.m&fs.ModeDir != 0
}

func (t *File) Name() string {
	return filepath.Base(t.Path)
}

func (t *File) Type() fs.FileMode {
	return Info{File: t}.Mode() & fs.ModeType
}

func (t *File) Close() error {
	return nil
}

func (t *File) Stat() (fs.FileInfo, error) {
	return Info{File: t}, nil
}

func (t *File) Read(p []byte) (int, error) {
	n, err := t.ReadAt(p, int64(t.index.Load()))
	t.index.Add(uint64(n))
	return n, err
}

func (t *File) ReadAt(p []byte, offset int64) (int, error) {
	return t.cache.ReadAt(p, offset)
}

func (t *File) Write(p []byte) (int, error) {
	n, err := t.WriteAt(p, int64(t.index.Load()))
	t.index.Add(uint64(n))
	return n, err
}

func (t *File) WriteAt(p []byte, offset int64) (int, error) {
	return t.cache.WriteAt(p, offset)
}

func (t *File) Seek(offset int64, whence int) (int64, error) {
	switch whence {
	case io.SeekStart:
		if offset < 0 {
			return 0, fmt.Errorf("file: seek to negative index: %d", offset)
		}
		t.index.Store(uint64(offset))
		return offset, nil
	case io.SeekEnd:
		res := int64(t.Length) + offset
		if res < 0 {
			return 0, fmt.Errorf("file: seek to negative index: %d", res)
		}
		t.index.Store(uint64(res))
		return res, nil
	default:
		cur := t.index.Load()
		res := int64(cur) + offset
		if res < 0 {
			return 0, fmt.Errorf("file: seek to negative index: %d", res)
		}
		t.index.Store(uint64(res))
		return res, nil
	}
}

func NewDirEntry(ts time.Time, path string, mod fs.FileMode, opts ...FileOption) *Dir {
	return &Dir{
		File: NewFile(nil, ts, path, 0, mod|fs.ModeDir, opts...),
	}
}

type Dir struct {
	*File
	ent []fs.DirEntry
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
	// log.Println("READDIR", t.Path, n, t.index.Load(), len(t.ent))
	// defer log.Println("READDIR COMPLETED")
	if n <= 0 {
		return t.ent, nil
	}

	if len(t.ent) == 0 {
		return nil, io.EOF
	}

	m := min(len(t.ent)-int(t.index.Load()), n)
	if m == 0 {
		return nil, io.EOF
	}

	return t.ent[t.index.Load():m], nil
}

type FS struct {
	tree   *trie.Trie[*Dir]
	mapped map[string]*File
	cache  *DirCache
}

// Open implements fs.StatFS.
func (t FS) Open(name string) (fs.File, error) {
	if f, ok := t.mapped[name]; ok {
		dup := *f
		return &dup, nil
	}

	if v, ok := t.tree.Get([]byte(name)); ok {
		return v, nil
	}

	rooted := "./" + name
	if v, ok := t.tree.Get([]byte(rooted)); ok {
		return v, nil
	}

	// log.Println("Open", name)
	// t.tree.Iterate(func(prefix []byte, value *Dir) {
	// 	log.Println("DERP", string(prefix), rooted, string(prefix) == name, string(prefix) == rooted)
	// })
	return nil, fs.ErrNotExist
}

// Stat implements fs.StatFS.
func (t FS) Stat(name string) (fs.FileInfo, error) {
	if f, ok := t.mapped[name]; ok {
		dup := *f
		return Info{File: &dup}, nil
	}

	if v, ok := t.tree.Get([]byte(name)); ok {
		dup := *v.File
		return Info{File: &dup}, nil
	}

	// log.Println("STAT", name)

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

func NewFS(dcache *DirCache, fns ...*File) FS {
	contents := make(map[string]*File, max(len(fns), 1))
	fstree := &trie.Trie[*Dir]{}

	for _, fn := range fns {
		fn.Path = strings.Replace(fn.Path, filepath.Base(dcache.root), ".", 1)
		contents[fn.Path] = fn
		var prev fs.DirEntry = fn
		for d, _ := filepath.Split(fn.Path); stringsx.Present(d); d, _ = filepath.Split(d) {
			d = strings.TrimSuffix(d, string(filepath.Separator))
			n := NewDirEntry(fn.ts, d, 0700)
			n.ent = append(n.ent, prev)
			if old := fstree.Put([]byte(d), n); old != nil {
				if old.IsDir() {
					n.ent = append(old.ent, n.ent...)
				}
			}
			prev = n
			// log.Println("dir", d, len(n.ent))
		}
	}

	return FS{cache: dcache, mapped: contents, tree: fstree}
}
