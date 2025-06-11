package cryptox_test

import (
	"crypto/cipher"
	"crypto/md5"
	"io"
	"testing"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/stretchr/testify/require"
	"golang.org/x/crypto/chacha20"
)

func EncryptionTest[T ~[]byte | string](t *testing.T, seed T, limit int64, r func(prng io.Reader, src io.Reader) (*cipher.StreamReader, error), w func(prng io.Reader, src io.Writer) (*cipher.StreamWriter, error)) {
	var (
		expected = md5.New()
		actual   = md5.New()
	)

	encrypt, err := cryptox.NewReaderChaCha20(
		cryptox.NewChaCha8(seed),
		io.LimitReader(
			io.TeeReader(cryptox.NewChaCha8(seed), expected),
			limit,
		),
	)
	require.NoError(t, err)

	decrypt, err := cryptox.NewWriterChaCha20(
		cryptox.NewChaCha8(seed),
		actual,
	)
	require.NoError(t, err)

	n, err := io.Copy(decrypt, encrypt)
	require.NoError(t, err)
	require.Equal(t, limit, n)
	require.Equal(t, expected.Sum(nil), actual.Sum(nil))
}

func TestNewReaderChaCha20(t *testing.T) {
	t.Run("should return an error if PRNG provides insufficient data for key", func(t *testing.T) {
		cipher, err := cryptox.NewReaderChaCha20(io.LimitReader(cryptox.NewChaCha8("derp"), chacha20.KeySize-1), cryptox.NewChaCha8("derp"))
		require.Error(t, err)
		require.Nil(t, cipher)
		require.Contains(t, err.Error(), "unexpected EOF")
	})

	t.Run("should return an error if PRNG provides insufficient data for nonce", func(t *testing.T) {
		cipher, err := cryptox.NewReaderChaCha20(io.LimitReader(cryptox.NewChaCha8("derp"), chacha20.KeySize), cryptox.NewChaCha8("derp"))

		require.Error(t, err)
		require.Nil(t, cipher)
		require.Contains(t, err.Error(), "EOF")
	})

	t.Run("returned cipher should be functional for encryption/decryption", func(t *testing.T) {
		EncryptionTest(t, uuid.Must(uuid.NewV4()).Bytes(), bytesx.MiB, cryptox.NewReaderChaCha20, cryptox.NewWriterChaCha20)
	})
}
