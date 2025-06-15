package uuidx_test

import (
	"testing"
	"time"

	"github.com/gofrs/uuid/v5"
	. "github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/stretchr/testify/require"
)

func TestUUIDX(t *testing.T) {
	t.Run("Advance16", func(t *testing.T) {
		runAdvance16Test := func(t *testing.T, u uuid.UUID, expected uuid.UUID, by uint16) {
			actual := Advance16(u, by)
			require.Equal(t, expected, actual, "Advance16(%v, %d) mismatch", u, by)
		}

		t.Run("advance by 1", func(t *testing.T) {
			runAdvance16Test(
				t,
				uuid.Nil,
				uuid.Must(uuid.FromString("00010000-0000-0000-0000-000000000000")),
				uint16(1),
			)
		})
	})

	t.Run("WithTimestampPrefix", func(t *testing.T) {
		runWithTimestampPrefixTest := func(t *testing.T, u uuid.UUID, ts time.Time, expected uuid.UUID) {
			actual := WithTimestampPrefix(u, ts)
			require.Equal(t, expected.String(), actual.String(), "WithTimestampPrefix(%v, %v) mismatch", u, ts)
		}

		t.Run("example - 1 millisecond after epoch", func(t *testing.T) {
			runWithTimestampPrefixTest(
				t,
				uuid.Nil,
				time.Unix(0, 1000),
				uuid.FromStringOrNil("00000000-0000-0001-0000-000000000000"),
			)
		})
	})
}

func TestFirstNonZero(t *testing.T) {
	t.Run("should return the first non-nil UUID when it's at the beginning", func(t *testing.T) {
		input := []uuid.UUID{
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000001")),
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000002")),
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000003")),
		}
		expected := uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000001"))
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return %v, got %v", expected, actual)
	})

	t.Run("should return the first non-nil UUID when it's in the middle", func(t *testing.T) {
		input := []uuid.UUID{
			uuid.Nil,
			uuid.Nil,
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000002")),
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000003")),
		}
		expected := uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000002"))
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return %v, got %v", expected, actual)
	})

	t.Run("should return the first non-nil UUID when it's at the end", func(t *testing.T) {
		input := []uuid.UUID{
			uuid.Nil,
			uuid.Nil,
			uuid.Nil,
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000003")),
		}
		expected := uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000003"))
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return %v, got %v", expected, actual)
	})

	t.Run("should return uuid.Nil if all UUIDs are nil", func(t *testing.T) {
		input := []uuid.UUID{uuid.Nil, uuid.Nil, uuid.Nil}
		expected := uuid.Nil
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return uuid.Nil, got %v", actual)
	})

	t.Run("should return uuid.Nil for an empty slice", func(t *testing.T) {
		input := []uuid.UUID{}
		expected := uuid.Nil
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return uuid.Nil for empty slice, got %v", actual)
	})

	t.Run("should handle a single non-nil UUID correctly", func(t *testing.T) {
		input := []uuid.UUID{
			uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000001")),
		}
		expected := uuid.Must(uuid.FromString("00000000-0000-0000-0000-000000000001"))
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return %v for single non-nil, got %v", expected, actual)
	})

	t.Run("should handle a single nil UUID correctly", func(t *testing.T) {
		input := []uuid.UUID{uuid.Nil}
		expected := uuid.Nil
		actual := FirstNonZero(input...)
		require.Equal(t, expected, actual, "Expected FirstNonZero to return uuid.Nil for single nil, got %v", actual)
	})
}
