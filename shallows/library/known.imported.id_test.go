package library_test

import (
	"math"
	"testing"

	"github.com/retrovibed/retrovibed/library"
	"github.com/stretchr/testify/require"
)

func TestKnownImportedUintID(t *testing.T) {
	t.Run("zero ID and simple prefix", func(t *testing.T) {
		require.Equal(t, "61626381-0000-0000-0000-000000000000", library.KnownImportedUintID("abc", 0))
	})

	t.Run("excessively long prefix", func(t *testing.T) {
		require.Equal(t, "6c6f6e67-0000-0000-0000-000000000000", library.KnownImportedUintID("long-prefix-for-id", 0))
	})

	t.Run("single digit ID", func(t *testing.T) {
		require.Equal(t, "746d6462-0000-0000-0000-000000000007", library.KnownImportedUintID("tmdb", 7))
	})

	t.Run("maximum uint64", func(t *testing.T) {
		require.Equal(t, "811c9dc5-0000-0000-00ff-ffffffffffff", library.KnownImportedUintID("", math.MaxUint64))
	})

	t.Run("highest byte all 1", func(t *testing.T) {
		require.Equal(t, "811c9dc5-0000-0000-00ff-000000000000", library.KnownImportedUintID("", 0xFFFF000000000000))
	})

	t.Run("empty prefix", func(t *testing.T) {
		require.Equal(t, "811c9dc5-0000-0000-0000-000000000000", library.KnownImportedUintID("", 0))
	})

	t.Run("prefix with special characters", func(t *testing.T) {
		require.Equal(t, "41214023-0000-0000-0000-000000000001", library.KnownImportedUintID("A!@#$", 1))
	})
}
