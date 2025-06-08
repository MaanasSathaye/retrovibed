package tracking

import (
	"encoding/hex"
	"testing"

	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/stretchr/testify/require"
)

func TestDescriptionFromPath(t *testing.T) {
	require.Equal(t, "example mp4", DescriptionFromPath(&Metadata{Infohash: md5x.Digest("example1").Sum(nil), Description: "derp0"}, "example.mp4"))
	require.Equal(t, "derp1", DescriptionFromPath(&Metadata{Infohash: md5x.Digest("example2").Sum(nil), Description: "derp1"}, md5x.FormatHex(md5x.Digest("example2"))))
}

func TestDescriptionFromPathFromMetadata(t *testing.T) {
	ctx, done := testx.Context(t)
	defer done()

	q := sqltestx.Metadatabase(t)
	defer q.Close()

	lmd := NewMetadata(
		langx.Autoptr(metainfo.NewHashFromBytes(int160.Random().Bytes())),
		MetadataOptionDescription("Hello World"),
	)

	require.NoError(t, MetadataInsertWithDefaults(ctx, q, lmd).Scan(&lmd))
	require.Equal(t, "Hello World", DescriptionFromPath(&lmd, hex.EncodeToString(lmd.Infohash)))
}
