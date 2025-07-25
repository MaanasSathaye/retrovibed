package rss_test

import (
	"bytes"
	"testing"
	"time"

	"github.com/retrovibed/retrovibed/internal/iterx"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/stretchr/testify/require"
)

func TestGenerate(t *testing.T) {
	t.Run("example 1 - 0 items", func(t *testing.T) {
		var (
			buf bytes.Buffer
		)
		path := testx.Fixture("generated", "example.1.xml")

		require.NoError(t, rss.Generator().Generate(&buf, rss.Channel{
			Title:         "Retrovibed Media Database",
			Link:          "https://media.community.retrovibe.space",
			Description:   "magnet links for media metadata archives for use by the retrovibed application",
			TTL:           1440,
			LastBuildDate: time.Date(2025, time.July, 22, 13, 02, 40, 0, time.UTC),
			Language:      "en-us",
			Copyright:     "Retrovibed 2025",
		}, iterx.From[rss.Item]()))

		require.Equal(t, testx.ReadMD5(path), testx.IOMD5(bytes.NewReader(buf.Bytes())), "invalid generation:\n%s\n-----------------\n%s", buf.String(), testx.ReadString(path))
	})

	t.Run("example 2 - 3 items", func(t *testing.T) {
		var (
			buf bytes.Buffer
		)
		path := testx.Fixture("generated", "example.2.xml")

		require.NoError(t, rss.Generator().Generate(&buf, rss.Channel{
			Title:         "Retrovibed Media Database",
			Link:          "https://media.community.retrovibe.space",
			Description:   "magnet links for media metadata archives for use by the retrovibed application",
			TTL:           1440,
			LastBuildDate: time.Date(2025, time.July, 22, 13, 02, 40, 0, time.UTC),
			Language:      "en-us",
			Copyright:     "Retrovibed 2025",
			Retrovibed: &rss.Retrovibed{
				Mimetype: "application/vnd.retrovibed.media.archive",
				Entropy:  "57869e82c2684ac4881bd32581f969db",
			},
		}, iterx.From(rss.Item{
			Guid:        "00000000-0000-0000-0000-000000000001",
			Title:       "Retrovibe Media Archive 00",
			Link:        "https://media.community.retrovibe.space/00000000-0000-0000-0000-000000000001",
			PublishDate: time.Date(2025, time.July, 22, 13, 02, 40, 0, time.UTC),
			Enclosures: []rss.Enclosure{{
				Length:   1243643904,
				Mimetype: mimex.Bittorrent,
				URL:      "magnet:?xt=urn:btih:8665727372B28B0263690B82928399516641A1B4&dn=retrovibed.media.metadata.00.gz",
			}},
		})))

		require.Equal(t, testx.ReadMD5(path), testx.IOMD5(bytes.NewReader(buf.Bytes())), "invalid generation:\n%s\n-----------------\n%s", buf.String(), testx.ReadString(path))
	})
}
