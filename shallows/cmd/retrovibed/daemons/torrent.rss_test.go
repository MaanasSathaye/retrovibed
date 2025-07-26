package daemons_test

import (
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/cmd/retrovibed/daemons"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrenttestx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/tracking"
	"github.com/stretchr/testify/require"
)

func TestDiscoverFromRSSFeeds(t *testing.T) {
	t.Run("should be able to locate and create torrent metadata from an rss feed", func(t *testing.T) {
		q := sqltestx.Metadatabase(t)
		defer q.Close()

		tclient := torrenttestx.QuickClient(t)
		defer tclient.Close()

		vfs := fsx.DirVirtual(t.TempDir())
		tstore := blockcache.NewTorrentFromVirtualFS(vfs)

		mux := http.NewServeMux()

		mux.HandleFunc("/index.xml", func(w http.ResponseWriter, r *http.Request) {
			v := strings.ReplaceAll(testx.ReadString(testx.Fixture("torrent.rss", "arch.linux", "index.xml")), "https://archlinux.org", fmt.Sprintf("http://%s", r.Host))
			httptestx.HandleIO(strings.NewReader(v))(w, r)
		})
		mux.HandleFunc("/releng/releases/{id}/torrent/", func(w http.ResponseWriter, r *http.Request) {
			httptestx.HandleIO(testx.Read(testx.Fixture("torrent.rss", "arch.linux"), fmt.Sprintf("%s.torrent", r.PathValue("id"))))(w, r)
		})
		srv := httptest.NewServer(mux)
		defer srv.Close()

		require.NoError(t, fsx.MkDirs(0700, vfs.Path("torrent")))

		feed := langx.Clone(tracking.RSS{}, tracking.RSSOptionDefaultFeeds(tracking.RSS{
			Description:    "Arch Linux - iso",
			URL:            fmt.Sprintf("%s/index.xml", srv.URL),
			Contributing:   true,
			Autodownload:   true,
			LastBuiltAt:    time.Date(2025, time.June, 01, 0, 0, 0, 0, time.UTC),
			EncryptionSeed: uuidx.WithSuffix(16),
		}), tracking.RSSOptionDefaultEncryptionSeed)

		require.NoError(t, tracking.RSSInsertDefaultFeed(t.Context(), q, feed).Scan(&feed))

		require.NotEqual(t, time.Date(2025, time.July, 01, 17, 47, 32, 0, time.UTC), feed.LastBuiltAt)
		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.NoError(t, daemons.DiscoverFromRSSFeedsOnce(t.Context(), q, vfs, tclient, tstore))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_metadata")))

		var (
			actual  tracking.Metadata
			updfeed tracking.RSS
		)

		require.NoError(t, tracking.RSSFindByID(t.Context(), q, feed.ID).Scan(&updfeed))
		require.Equal(t, time.Date(2025, time.July, 01, 17, 47, 32, 0, time.UTC), updfeed.LastBuiltAt)

		require.NoError(t, tracking.MetadataFindByID(t.Context(), q, errorsx.Must(sqlx.String(t.Context(), q, "SELECT id::text FROM torrents_metadata"))).Scan(&actual))
		// these values should all be generated consistently
		require.Equal(t, "9f676b73-25ef-674d-6443-c90e562c28db", actual.ID)
		require.Equal(t, "3ae42d96-ac70-58a7-c9f2-71ecb1c36232", actual.EncryptionSeed)
		require.EqualValues(t, 0x50ea8000, actual.Bytes)
		require.False(t, actual.Private)
		require.False(t, actual.Archivable)
		require.True(t, actual.InitiatedAt.Before(time.Now().Add(time.Millisecond)))
	})

	t.Run("should skip feeds with newer last build dates", func(t *testing.T) {
		q := sqltestx.Metadatabase(t)
		defer q.Close()

		tclient := torrenttestx.QuickClient(t)
		vfs := fsx.DirVirtual(t.TempDir())
		tstore := blockcache.NewTorrentFromVirtualFS(vfs)

		mux := http.NewServeMux()

		mux.HandleFunc("/index.xml", func(w http.ResponseWriter, r *http.Request) {
			v := strings.ReplaceAll(testx.ReadString(testx.Fixture("torrent.rss", "arch.linux", "index.xml")), "https://archlinux.org", fmt.Sprintf("http://%s", r.Host))
			httptestx.HandleIO(strings.NewReader(v))(w, r)
		})
		mux.HandleFunc("/releng/releases/{id}/torrent/", func(w http.ResponseWriter, r *http.Request) {
			httptestx.HandleIO(testx.Read(testx.Fixture("torrent.rss", "arch.linux"), fmt.Sprintf("%s.torrent", r.PathValue("id"))))(w, r)
		})
		srv := httptest.NewServer(mux)
		defer srv.Close()

		require.NoError(t, fsx.MkDirs(0700, vfs.Path("torrent")))

		feed := langx.Clone(tracking.RSS{}, tracking.RSSOptionDefaultFeeds(tracking.RSS{
			Description:  "Arch Linux - iso",
			URL:          fmt.Sprintf("%s/index.xml", srv.URL),
			Contributing: true,
			LastBuiltAt:  time.Now(),
		}), tracking.RSSOptionDefaultEncryptionSeed)

		require.NoError(t, tracking.RSSInsertDefaultFeed(t.Context(), q, feed).Scan(&feed))

		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.NoError(t, daemons.DiscoverFromRSSFeedsOnce(t.Context(), q, vfs, tclient, tstore))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_metadata")))
	})

	t.Run("should skip feeds with equal last build dates", func(t *testing.T) {
		q := sqltestx.Metadatabase(t)
		defer q.Close()

		tclient := torrenttestx.QuickClient(t)
		vfs := fsx.DirVirtual(t.TempDir())
		tstore := blockcache.NewTorrentFromVirtualFS(vfs)

		mux := http.NewServeMux()

		mux.HandleFunc("/index.xml", func(w http.ResponseWriter, r *http.Request) {
			v := strings.ReplaceAll(testx.ReadString(testx.Fixture("torrent.rss", "arch.linux", "index.xml")), "https://archlinux.org", fmt.Sprintf("http://%s", r.Host))
			httptestx.HandleIO(strings.NewReader(v))(w, r)
		})
		mux.HandleFunc("/releng/releases/{id}/torrent/", func(w http.ResponseWriter, r *http.Request) {
			httptestx.HandleIO(testx.Read(testx.Fixture("torrent.rss", "arch.linux"), fmt.Sprintf("%s.torrent", r.PathValue("id"))))(w, r)
		})
		srv := httptest.NewServer(mux)
		defer srv.Close()

		require.NoError(t, fsx.MkDirs(0700, vfs.Path("torrent")))

		feed := langx.Clone(tracking.RSS{}, tracking.RSSOptionDefaultFeeds(tracking.RSS{
			Description:  "Arch Linux - iso",
			URL:          fmt.Sprintf("%s/index.xml", srv.URL),
			Contributing: true,
			LastBuiltAt:  time.Date(2025, time.July, 01, 17, 47, 32, 0, time.UTC),
		}), tracking.RSSOptionDefaultEncryptionSeed)

		require.NoError(t, tracking.RSSInsertDefaultFeed(t.Context(), q, feed).Scan(&feed))

		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.NoError(t, daemons.DiscoverFromRSSFeedsOnce(t.Context(), q, vfs, tclient, tstore))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_metadata")))
	})

	t.Run("should skip items from before feeds last sync", func(t *testing.T) {
		q := sqltestx.Metadatabase(t)
		defer q.Close()

		tclient := torrenttestx.QuickClient(t)
		vfs := fsx.DirVirtual(t.TempDir())
		tstore := blockcache.NewTorrentFromVirtualFS(vfs)

		mux := http.NewServeMux()

		mux.HandleFunc("/index.xml", func(w http.ResponseWriter, r *http.Request) {
			v := strings.ReplaceAll(testx.ReadString(testx.Fixture("torrent.rss", "example.2", "index.xml")), "https://archlinux.org", fmt.Sprintf("http://%s", r.Host))
			httptestx.HandleIO(strings.NewReader(v))(w, r)
		})
		mux.HandleFunc("/releng/releases/{id}/torrent/", func(w http.ResponseWriter, r *http.Request) {
			httptestx.HandleIO(testx.Read(testx.Fixture("torrent.rss", "arch.linux"), fmt.Sprintf("%s.torrent", r.PathValue("id"))))(w, r)
		})
		srv := httptest.NewServer(mux)
		defer srv.Close()

		require.NoError(t, fsx.MkDirs(0700, vfs.Path("torrent")))

		feed := langx.Clone(tracking.RSS{}, tracking.RSSOptionDefaultFeeds(tracking.RSS{
			Description:  "Arch Linux - iso",
			URL:          fmt.Sprintf("%s/index.xml", srv.URL),
			Contributing: true,
			LastBuiltAt:  time.Date(2025, time.July, 01, 17, 0, 0, 0, time.UTC),
		}), tracking.RSSOptionDefaultEncryptionSeed)

		require.NoError(t, tracking.RSSInsertDefaultFeed(t.Context(), q, feed).Scan(&feed))

		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.NoError(t, daemons.DiscoverFromRSSFeedsOnce(t.Context(), q, vfs, tclient, tstore))
		require.Equal(t, 0, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")))
		require.Equal(t, 1, errorsx.Zero(sqlx.Count(t.Context(), q, "SELECT COUNT (*) FROM torrents_metadata")))
	})
}
