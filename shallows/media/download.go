package media

import (
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/retrovibed/retrovibed/internal/grpcx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/tracking"
)

type DownloadOption func(*Download)

func DownloadOptionFromTorrentMetadata(cc tracking.Metadata) DownloadOption {
	return func(c *Download) {
		c.Media = langx.Autoptr(langx.Clone(Media{}, MediaOptionFromTorrentMetadata(cc)))
		c.Bytes = cc.Bytes
		c.Downloaded = cc.Downloaded
		c.Peers = uint32(cc.Peers)
		c.PausedAt = grpcx.EncodeTime(cc.PausedAt)
		c.Distributing = cc.Seeding
		c.Path = int160.FromBytes(cc.Infohash).String()
	}
}
