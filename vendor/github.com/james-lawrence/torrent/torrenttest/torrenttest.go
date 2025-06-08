// Package torrenttest contains functions for testing torrent-related behaviour.
//

package torrenttest

import (
	"crypto/md5"
	"crypto/rand"
	"hash"
	"io"
	mrand "math/rand/v2"
	"os"
	"path/filepath"

	"github.com/james-lawrence/torrent/internal/errorsx"
	"github.com/james-lawrence/torrent/metainfo"
)

func Random(dir string, n int64, options ...metainfo.Option) (id metainfo.Hash, info *metainfo.Info, digested hash.Hash, err error) {
	digested = md5.New()

	src, err := IO(dir, io.TeeReader(rand.Reader, digested), n)
	if err != nil {
		return id, nil, nil, err
	}
	defer src.Close()

	info, err = metainfo.NewFromPath(src.Name(), options...)
	if err != nil {
		return id, nil, nil, err
	}

	id, err = metainfo.NewHashFromInfo(info)
	if err != nil {
		return id, nil, nil, err
	}

	dstdir := filepath.Join(dir, id.HexString())
	if err = os.MkdirAll(filepath.Dir(dstdir), 0700); err != nil {
		return id, nil, nil, err
	}

	if err = os.Rename(src.Name(), dstdir); err != nil {
		return id, nil, nil, err
	}

	return id, info, digested, nil
}

func RandomMulti(dir string, n int, min int64, max int64, options ...metainfo.Option) (id metainfo.Hash, info *metainfo.Info, err error) {
	root, err := os.MkdirTemp(dir, "multi.torrent.*")
	if err != nil {
		return id, nil, err
	}

	rsrc := mrand.New(NewChaCha8(root))
	addfile := func() error {
		bytes := rsrc.Int64N(max-min) + min
		src, err := IO(root, rand.Reader, bytes)
		return errorsx.Compact(err, src.Close())
	}

	for range n {
		if err := addfile(); err != nil {
			return id, nil, err
		}
	}

	info, err = metainfo.NewFromPath(root, options...)
	if err != nil {
		return id, nil, err
	}

	id, err = metainfo.NewHashFromInfo(info)
	if err != nil {
		return id, nil, err
	}

	dstdir := filepath.Join(dir, id.HexString())
	if err = os.Rename(root, dstdir); err != nil {
		return id, nil, err
	}

	return id, info, nil
}

// generates a torrent from the provided io.Reader
func IO(dir string, src io.Reader, n int64) (d *os.File, err error) {
	if d, err = os.CreateTemp(dir, "random.torrent.*.bin"); err != nil {
		return d, err
	}
	defer func() {
		if err != nil {
			os.Remove(d.Name())
		}
	}()

	if _, err = io.CopyN(d, src, n); err != nil {
		return d, err
	}

	if _, err = d.Seek(0, io.SeekStart); err != nil {
		return d, err
	}

	return d, nil
}

func NewChaCha8[T ~[]byte | string](seed T) *mrand.ChaCha8 {
	var (
		vector [32]byte
		source = []byte(seed)
	)

	v1 := md5.Sum(source)
	v2 := md5.Sum(append(v1[:], source...))
	copy(vector[:15], v1[:])
	copy(vector[16:], v2[:])

	return mrand.NewChaCha8(vector)
}
