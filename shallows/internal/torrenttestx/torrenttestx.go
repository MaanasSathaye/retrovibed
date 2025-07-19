package torrenttestx

import (
	"log"
	"testing"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
)

func QuickClient(t testing.TB, options ...torrent.ClientConfigOption) *torrent.Client {
	cdir := t.TempDir()
	return testx.Must(testx.Must(torrentx.Autosocket(0))(t).Bind(
		torrent.NewClient(
			torrent.NewDefaultClientConfig(
				torrent.NewMetadataCache(cdir),
				storage.NewFile(cdir),
				torrent.ClientConfigCacheDirectory(cdir),
				torrent.ClientConfigPeerID(krpc.RandomID().String()),
				torrent.ClientConfigSeed(true),
				torrent.ClientConfigInfoLogger(log.New(log.Writer(), "[torrent] ", log.Flags())),
				torrent.ClientConfigMuxer(dht.DefaultMuxer()),
				torrent.ClientConfigBucketLimit(32),
				torrent.ClientConfigCompose(options...),
				torrent.ClientConfigDialPoolSize(1),
			),
		),
	))(t)
}
