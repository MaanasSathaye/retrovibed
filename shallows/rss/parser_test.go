package rss_test

import (
	"testing"

	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/stretchr/testify/require"
)

func TestParseFixture(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()
	_, parsed, err := rss.Parse(ctx, testx.Read(testx.Fixture("example.1.xml")))
	require.NoError(t, err)
	require.Equal(t, len(parsed), 50)
}

func TestParseSupportEnclosures(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()

	_, parsed, err := rss.Parse(ctx, testx.Read(testx.Fixture("example.2.xml")))
	require.NoError(t, err)
	require.Equal(t, len(parsed), 3)
	require.Equal(t, rss.FindEnclosureURLByMimetype("application/x-bittorrent", parsed...), []string{
		"https://archlinux.org//releng/releases/2025.04.01/torrent/",
		"https://archlinux.org//releng/releases/2025.03.01/torrent/",
		"https://archlinux.org//releng/releases/2025.02.01/torrent/",
	})
}
