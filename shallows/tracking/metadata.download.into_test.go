package tracking_test

import (
	"crypto/md5"
	"os"
	"path/filepath"
	"testing"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/storage"
	"github.com/james-lawrence/torrent/torrenttest"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrenttestx"
	"github.com/retrovibed/retrovibed/tracking"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestDownloadInto(t *testing.T) {
	t.Run("properly download a multitorrent", func(t *testing.T) {
		var (
			actual   = md5.New()
			expected = md5.New()
		)

		ctx := t.Context()
		q := sqltestx.Metadatabase(t)
		defer q.Close()

		seedir := t.TempDir()

		mi, err := torrenttest.RandomMulti(seedir, 5, 16*bytesx.KiB, 64*bytesx.KiB)
		require.NoError(t, err)

		seeder := torrenttestx.Client(
			t,
			torrent.NewMetadataCache(seedir),
			blockcache.NewTorrentFromVirtualFS(fsx.DirVirtual(seedir)),
		)

		md, err := torrent.NewFromInfo(mi, torrent.OptionStorage(storage.NewFile(filepath.Join(seedir))))
		require.NoError(t, err)

		seederTorrent, _, err := seeder.Start(md)
		require.NoError(t, err)
		defer seeder.Close()

		require.NoError(t, torrent.Verify(ctx, seederTorrent))
		n, err := torrent.DownloadInto(ctx, expected, seederTorrent, torrent.TuneSeeding)
		require.NoError(t, err)
		require.Equal(t, mi.TotalLength(), n)

		root := fsx.DirVirtual(t.TempDir())

		leechdir := root.Path("torrent")
		mediadir := root.Path("media")
		require.NoError(t, fsx.MkDirs(0700, leechdir, mediadir))

		leecher := torrenttestx.Client(
			t,
			torrent.NewMetadataCache(leechdir),
			blockcache.NewTorrentFromVirtualFS(fsx.DirVirtual(leechdir)),
		)
		defer leecher.Close()

		lmd := tracking.NewMetadata(
			&md.ID,
			tracking.MetadataOptionFromInfo(mi),
			tracking.MetadataOptionAutoDescription,
		)

		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, lmd).Scan(&lmd))

		ltor, added, err := leecher.MaybeStart(
			torrent.NewFromInfo(
				mi,
			),
		)
		require.NoError(t, err)
		assert.True(t, added)

		require.NoError(t, ltor.Tune(torrent.TuneClientPeer(seeder)))

		require.NoError(t, tracking.DownloadInto(t.Context(), q, root, &lmd, ltor, actual))

		require.Equal(t, md5x.FormatUUID(expected), md5x.FormatUUID(actual))

		w0 := fsx.Walk(os.DirFS(leechdir))
		require.EqualValues(t, 3, testx.Seq2Count(w0.Walk()))
		require.NoError(t, w0.Err())

		w1 := fsx.Walk(os.DirFS(mediadir))
		require.EqualValues(t, 6, testx.Seq2Count(w1.Walk()))
		require.NoError(t, w1.Err())
	})
}
