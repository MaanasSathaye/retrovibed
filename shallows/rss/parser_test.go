package rss_test

import (
	"testing"
	"time"

	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/stretchr/testify/require"
)

func TestParse(t *testing.T) {
	t.Run("example 1 - basic rss feed", func(t *testing.T) {
		ctx, done := testx.Context(t)
		defer done()
		_, parsed, err := rss.Parse(ctx, testx.Read(testx.Fixture("parsing", "example.1.xml")))
		require.NoError(t, err)
		require.Equal(t, len(parsed), 50)
	})

	t.Run("example 2 - enclosures", func(t *testing.T) {
		ctx, done := testx.Context(t)
		defer done()

		_, parsed, err := rss.Parse(ctx, testx.Read(testx.Fixture("parsing", "example.2.xml")))
		require.NoError(t, err)
		require.Equal(t, len(parsed), 3)
		require.Equal(t, rss.FindEnclosureURLByMimetype(mimex.Bittorrent, parsed...), []string{
			"https://archlinux.org//releng/releases/2025.04.01/torrent/",
			"https://archlinux.org//releng/releases/2025.03.01/torrent/",
			"https://archlinux.org//releng/releases/2025.02.01/torrent/",
		})
	})

	t.Run("example 3 - retrovibed extensions", func(t *testing.T) {
		channel, parsed, err := rss.Parse(t.Context(), testx.Read(testx.Fixture("parsing", "example.3.xml")))
		require.NoError(t, err)
		require.Equal(t, len(parsed), 1)
		require.EqualValues(t, 1440, channel.TTL)
		require.Equal(t, "en-us", channel.Language)
		require.Equal(t, time.Date(2025, time.July, 22, 13, 2, 40, 0, time.FixedZone("+0000", 0)), channel.LastBuildDate.Timestamp(time.Now()))
		require.Equal(t, "Retrovibed Media Database", channel.Title)
		require.Equal(t, "57869e82c2684ac4881bd32581f969db", channel.Retrovibed.Entropy)
		require.Equal(t, "application/vnd.retrovibed.media.archive", channel.Retrovibed.Mimetype)
		require.Equal(t, rss.FindEnclosureURLByMimetype(mimex.Bittorrent, parsed...), []string{
			"magnet:?xt=urn:btih:8665727372B28B0263690B82928399516641A1B4&dn=retrovibed.media.metadata.00.gz",
		})
	})
}
