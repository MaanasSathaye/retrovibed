package cryptox

import (
	"crypto/cipher"
	"crypto/md5"
	"crypto/sha512"
	"io"
	"math/rand/v2"

	"golang.org/x/crypto/chacha20"
)

// NewPRNGSHA512 generate a csprng using sha512.
func NewPRNGSHA512(seed []byte) *sha512csprng {
	digest := sha512.Sum512(seed)
	return &sha512csprng{
		state: digest[:],
	}
}

type sha512csprng struct {
	state []byte
}

func (t *sha512csprng) Read(b []byte) (n int, err error) {
	for i := len(b); i > 0; i = i - len(t.state) {
		t.state = t.update(t.state)

		random := t.state
		if i < len(t.state) {
			random = t.state[:i]
		}

		n += copy(b[n:], random)
	}

	return n, nil
}

func (t *sha512csprng) update(state []byte) []byte {
	digest := sha512.Sum512(state)
	return digest[:]
}

func NewChaCha8[T ~[]byte | string](seed T) *rand.ChaCha8 {
	var (
		vector [32]byte
		source = []byte(seed)
	)

	v1 := md5.Sum(source)
	v2 := md5.Sum(append(v1[:], source...))
	copy(vector[:15], v1[:])
	copy(vector[16:], v2[:])

	return rand.NewChaCha8(vector)
}

func NewReaderChaCha20(prng, src io.Reader) (*cipher.StreamReader, error) {
	key := make([]byte, chacha20.KeySize)
	if _, err := io.ReadFull(prng, key); err != nil {
		return nil, err
	}

	nonce := make([]byte, chacha20.NonceSize)
	if _, err := io.ReadFull(prng, nonce); err != nil {
		return nil, err
	}

	s, err := chacha20.NewUnauthenticatedCipher(key, nonce)
	if err != nil {
		return nil, err
	}

	return &cipher.StreamReader{
		S: s,
		R: src,
	}, nil
}

func NewWriterChaCha20(prng io.Reader, dst io.Writer) (*cipher.StreamWriter, error) {
	key := make([]byte, chacha20.KeySize)
	if _, err := io.ReadFull(prng, key); err != nil {
		return nil, err
	}

	nonce := make([]byte, chacha20.NonceSize)
	if _, err := io.ReadFull(prng, nonce); err != nil {
		return nil, err
	}

	s, err := chacha20.NewUnauthenticatedCipher(key, nonce)
	if err != nil {
		return nil, err
	}
	return &cipher.StreamWriter{
		S: s,
		W: dst,
	}, nil
}

func NewOffsetWriterChaCha20(prng io.Reader, dst io.Writer, offset uint32) (*cipher.StreamWriter, error) {
	key := make([]byte, chacha20.KeySize)
	if _, err := io.ReadFull(prng, key); err != nil {
		return nil, err
	}

	nonce := make([]byte, chacha20.NonceSize)
	if _, err := io.ReadFull(prng, nonce); err != nil {
		return nil, err
	}

	s, err := chacha20.NewUnauthenticatedCipher(key, nonce)
	if err != nil {
		return nil, err
	}

	s.SetCounter(offset / 64)

	return &cipher.StreamWriter{
		S: s,
		W: dst,
	}, nil
}
