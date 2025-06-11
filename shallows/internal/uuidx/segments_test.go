package uuidx_test

import (
	"testing"

	"github.com/gofrs/uuid/v5"
	. "github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/stretchr/testify/require"
)

func TestSegmenter(t *testing.T) {
	// This t.Run block directly corresponds to your Ginkgo 'It' block.
	t.Run("should generate all segments", func(t *testing.T) {
		ranges := make([]Range, 0, 1024)
		for i, s := 0, NewSegmenter(); s.Next(); i++ {
			ranges = append(ranges, s.Range())
		}

		// Translating Ginkgo's Expect().To(Equal()) to testify/require.Equal()
		require.Equal(t, 1024, len(ranges), "Expected number of segments to be 1024")

		// Translating the first range assertion
		require.Equal(t, Range{
			Begin: uuid.Nil,
			End:   Advance16(uuid.Nil, 64),
		}, ranges[0], "First segment range mismatch")

		// Translating the last range assertion
		require.Equal(t, Range{
			Begin: uuid.FromStringOrNil("ffc00000-0000-0000-0000-000000000000"),
			End:   uuid.Max,
		}, ranges[1023], "Last segment range mismatch")
	})
}
