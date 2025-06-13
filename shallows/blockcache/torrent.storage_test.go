package blockcache_test

import (
	"crypto/md5"
	"io/fs"
	"log"
	"os"
	"path/filepath"
	"testing"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/autobind"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/james-lawrence/torrent/torrenttest"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestingConfig(t testing.TB, mdstore torrent.MetadataStore, store storage.ClientImpl, options ...torrent.ClientConfigOption) *torrent.ClientConfig {
	return torrent.NewDefaultClientConfig(
		mdstore,
		store,
		torrent.ClientConfigDHTEnabled(false),
		torrent.ClientConfigPortForward(false),
		torrent.ClientConfigDebugLogger(log.New(os.Stderr, "[debug] ", log.Flags())),
		torrent.ClientConfigCompose(options...),
	)
}

func testClientTransfer(t *testing.T, seedercfg, leechercfg torrent.ClientConfigOption) {
	var (
		actual   = md5.New()
		expected = md5.New()
	)

	ctx := t.Context()
	seedir := t.TempDir()

	mi, err := torrenttest.RandomMulti(seedir, 3, 16*bytesx.MiB, 64*bytesx.MiB)
	require.NoError(t, err)

	// Create seeder and a Torrent.
	cfg := TestingConfig(
		t,
		torrent.NewMetadataCache(seedir),
		blockcache.NewTorrentFromVirtualFS(fsx.DirVirtual(seedir)),
		torrent.ClientConfigSeed(true),
		seedercfg,
	)

	seeder, err := autobind.NewLoopback().Bind(torrent.NewClient(cfg))
	require.NoError(t, err)

	md, err := torrent.NewFromInfo(mi, torrent.OptionStorage(storage.NewFile(filepath.Join(seedir))))
	require.NoError(t, err)

	seederTorrent, _, err := seeder.Start(md)
	require.NoError(t, err)
	// Run a Stats right after Closing the Client. This will trigger the Stats
	// panic in #214 caused by RemoteAddr on Closed uTP sockets.
	defer seederTorrent.Stats()
	defer seeder.Close()

	require.NoError(t, torrent.Verify(ctx, seederTorrent))
	n, err := torrent.DownloadInto(ctx, expected, seederTorrent, torrent.TuneSeeding)
	require.NoError(t, err)
	require.Equal(t, mi.TotalLength(), n)

	leechdir := t.TempDir()
	cfg = TestingConfig(
		t,
		torrent.NewMetadataCache(leechdir),
		blockcache.NewTorrentFromVirtualFS(fsx.DirVirtual(leechdir)),
		torrent.ClientConfigSeed(false),
		leechercfg,
	)

	leecher, err := autobind.NewLoopback().Bind(torrent.NewClient(cfg))
	require.NoError(t, err)
	defer leecher.Close()

	leecherTorrent, added, err := leecher.MaybeStart(
		torrent.NewFromInfo(
			mi,
		),
	)
	require.NoError(t, err)
	assert.True(t, added)

	// Now do some things with leecher and seeder.
	require.NoError(t, leecherTorrent.Tune(torrent.TuneClientPeer(seeder)))

	// The Torrent should not be interested in obtaining peers, so the one we
	// just added should be the only one.
	require.False(t, leecherTorrent.Stats().Seeding)

	// begin downloading
	_, err = torrent.DownloadInto(ctx, actual, leecherTorrent)
	require.NoError(t, err)

	// fsx.PrintFS(os.DirFS(leechdir))
	// log.Println("WAAAT", md5x.FormatUUID(expected), md5x.FormatUUID(actual))

	// seederStats := seederTorrent.Stats()
	// assert.GreaterOrEqual(t, mi.Length, seederStats.BytesWrittenData.Int64())

	// leecherStats := leecherTorrent.Stats()
	// assert.GreaterOrEqual(t, mi.Length, leecherStats.BytesReadData.Int64())
	require.Equal(t, md5x.FormatUUID(expected), md5x.FormatUUID(actual))
}

func TestClientTransferDefault(t *testing.T) {
	testClientTransfer(t, torrent.ClientConfigNoop, torrent.ClientConfigNoop)
}

func TestTorrentFileSystem(t *testing.T) {
	dir := t.TempDir()
	info, err := torrenttest.RandomMulti(dir, 5, bytesx.KiB, bytesx.MiB)
	require.NoError(t, err)

	bcache, err := blockcache.NewDirectoryCache(dir)
	require.NoError(t, err)
	fsys := blockcache.TorrentFilesystem(bcache, info)

	count := 0
	err = fs.WalkDir(fsys, ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		// log.Println("DERP DERP", path, d.Name())

		if d.IsDir() {
			// log.Println("Directory", path)
			return nil
		}

		for d := range metainfo.Files(info) {
			if path == d.Path {
				count++
				return nil
				// } else {
				// 	log.Println("sad", d.Path)
			}
		}

		return nil
	})
	require.NoError(t, err)
	require.Equal(t, 5, count)
}
