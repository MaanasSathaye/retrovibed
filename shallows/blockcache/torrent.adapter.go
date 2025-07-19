package blockcache

import (
	"sync/atomic"

	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"

	"github.com/retrovibed/retrovibed/internal/fsx"
)

func NewTorrentFromVirtualFS(v fsx.Virtual) *TorrentCacheStorage {
	return &TorrentCacheStorage{v: v}
}

var _ storage.ClientImpl = &TorrentCacheStorage{}

type TorrentCacheStorage struct {
	v fsx.Virtual
}

func (t *TorrentCacheStorage) OpenTorrent(info *metainfo.Info, infoHash metainfo.Hash) (storage.TorrentImpl, error) {
	dir := storage.InfoHashPathMaker(t.v.Path(), infoHash, info, nil)

	cache, err := NewDirectoryCache(dir)
	if err != nil {
		return nil, err
	}

	return &fileTorrentImpl{
		cache: cache,
	}, nil
}

func (t *TorrentCacheStorage) Close() error {
	return nil
}

type fileTorrentImpl struct {
	closed atomic.Bool
	cache  *DirCache
}

func (t *fileTorrentImpl) ReadAt(p []byte, off int64) (n int, err error) {
	if t.closed.Load() {
		return 0, storage.ErrClosed()
	}

	return t.cache.ReadAt(p, off)
}

func (t *fileTorrentImpl) WriteAt(p []byte, off int64) (n int, err error) {
	if t.closed.Load() {
		return 0, storage.ErrClosed()
	}

	return t.cache.WriteAt(p, off)
}

func (t *fileTorrentImpl) Close() error {
	t.closed.Store(true)
	return nil
}
