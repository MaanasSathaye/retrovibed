package library_test

import (
	"bytes"
	"crypto/md5"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"testing"
	"time"

	"github.com/gofrs/uuid/v5"
	"github.com/gorilla/mux"
	"github.com/justinas/alice"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/stretchr/testify/require"
)

func TestDeeppoolReaderAtDownload(t *testing.T) {
	download := func(src io.Reader, n int64) http.HandlerFunc {
		var (
			buf bytes.Buffer
		)

		_n, err := io.Copy(&buf, io.LimitReader(src, n))
		require.NoError(t, err)
		require.EqualValues(t, n, _n)

		return func(w http.ResponseWriter, r *http.Request) {
			http.ServeContent(w, r, "test.bin", time.Date(2025, time.July, 01, 0, 0, 0, 0, time.UTC), io.NewSectionReader(bytes.NewReader(buf.Bytes()), 0, n))
		}
	}

	t.Run("full download - n % DefaultBlockSize == 0", func(t *testing.T) {
		const nlen = 128 * bytesx.MiB

		var (
			digest = md5.New()
			seed   = errorsx.Must(uuid.NewV4())
		)

		md := library.NewMetadata(uuidx.WithSuffix(1), library.MetadataOptionEncryptionSeed(seed.String()), library.MetadataOptionBytes(nlen))
		src, err := cryptox.NewReaderChaCha20(library.MetadataChaCha8(md), io.TeeReader(cryptox.NewChaCha8(seed.String()), digest))
		require.NoError(t, err)

		routes := mux.NewRouter()
		routes.Handle("/m/{id}/download", alice.New().ThenFunc(download(src, nlen)))

		srv := httptest.NewServer(routes)
		defer srv.Close()

		c := &http.Client{}
		c.Transport = httpx.RewriteHostTransport(testx.Must(url.ParseRequestURI(srv.URL))(t), c.Transport)

		reader := library.NewDeeppoolReaderAt(c, md, testx.Must(blockcache.NewDirectoryCache(t.TempDir()))(t))

		downloaded := md5.New()
		n, err := io.CopyN(downloaded, io.NewSectionReader(reader, 0, nlen), nlen)
		require.NoError(t, err)
		require.EqualValues(t, nlen, n)

		require.Equal(t, md5x.FormatUUID(digest), md5x.FormatUUID(downloaded))
	})

	t.Run("full download - n % DefaultBlockSize == 1", func(t *testing.T) {
		const nlen = 128*bytesx.MiB + 1

		var (
			digest = md5.New()
			seed   = errorsx.Must(uuid.NewV4())
		)

		md := library.NewMetadata(uuidx.WithSuffix(1), library.MetadataOptionEncryptionSeed(seed.String()), library.MetadataOptionBytes(nlen))
		src, err := cryptox.NewReaderChaCha20(library.MetadataChaCha8(md), io.TeeReader(cryptox.NewChaCha8(seed.String()), digest))
		require.NoError(t, err)

		routes := mux.NewRouter()
		routes.Handle("/m/{id}/download", alice.New().ThenFunc(download(src, nlen)))

		srv := httptest.NewServer(routes)
		defer srv.Close()

		c := &http.Client{}
		c.Transport = httpx.RewriteHostTransport(testx.Must(url.ParseRequestURI(srv.URL))(t), c.Transport)

		reader := library.NewDeeppoolReaderAt(c, md, testx.Must(blockcache.NewDirectoryCache(t.TempDir()))(t))

		downloaded := md5.New()
		n, err := io.CopyN(downloaded, io.NewSectionReader(reader, 0, nlen), nlen)
		require.NoError(t, err)
		require.EqualValues(t, nlen, n)
		require.Equal(t, md5x.FormatUUID(digest), md5x.FormatUUID(downloaded))
	})

	t.Run("full download - n % DefaultBlockSize == DefaultBlockSize-1", func(t *testing.T) {
		const nlen = 128*bytesx.MiB - 1

		var (
			digest = md5.New()
			seed   = errorsx.Must(uuid.NewV4())
		)

		md := library.NewMetadata(uuidx.WithSuffix(1), library.MetadataOptionEncryptionSeed(seed.String()), library.MetadataOptionBytes(nlen))
		src, err := cryptox.NewReaderChaCha20(library.MetadataChaCha8(md), io.TeeReader(cryptox.NewChaCha8(seed.String()), digest))
		require.NoError(t, err)

		routes := mux.NewRouter()
		routes.Handle("/m/{id}/download", alice.New().ThenFunc(download(src, nlen)))

		srv := httptest.NewServer(routes)
		defer srv.Close()

		c := &http.Client{}
		c.Transport = httpx.RewriteHostTransport(testx.Must(url.ParseRequestURI(srv.URL))(t), c.Transport)

		reader := library.NewDeeppoolReaderAt(c, md, testx.Must(blockcache.NewDirectoryCache(t.TempDir()))(t))

		downloaded := md5.New()
		n, err := io.CopyN(downloaded, io.NewSectionReader(reader, 0, nlen), nlen)
		require.NoError(t, err)
		require.EqualValues(t, nlen, n)
		require.Equal(t, md5x.FormatUUID(digest), md5x.FormatUUID(downloaded))
	})

	t.Run("range read the 2nd 16 KiB middle block of the data", func(t *testing.T) {
		const (
			nlen = 128 * bytesx.MiB
			clen = 33*bytesx.MiB + 16*bytesx.KiB
		)

		var ()

		md := library.NewMetadata(uuidx.WithSuffix(1), library.MetadataOptionEncryptionSeed(md5x.String(t.Name())))
		src, err := cryptox.NewReaderChaCha20(library.MetadataChaCha8(md), cryptox.NewChaCha8(t.Name()))
		require.NoError(t, err)

		routes := mux.NewRouter()
		routes.Handle("/m/{id}/download", alice.New().ThenFunc(download(src, nlen)))

		srv := httptest.NewServer(routes)
		defer srv.Close()

		c := &http.Client{}
		c.Transport = httpx.RewriteHostTransport(testx.Must(url.ParseRequestURI(srv.URL))(t), c.Transport)

		var (
			buf    bytes.Buffer
			digest = md5.New()
		)

		_n, err := io.Copy(&buf, io.LimitReader(cryptox.NewChaCha8(t.Name()), nlen))
		require.NoError(t, err)
		require.EqualValues(t, nlen, _n)
		require.EqualValues(t, nlen, len(buf.Bytes()))

		_n, err = io.Copy(digest, io.NewSectionReader(bytes.NewReader(buf.Bytes()), clen, 16*bytesx.KiB))
		require.NoError(t, err)
		require.EqualValues(t, 16*bytesx.KiB, _n)

		reader := library.NewDeeppoolReaderAt(c, md, testx.Must(blockcache.NewDirectoryCache(t.TempDir()))(t))

		downloaded := md5.New()
		n, err := io.Copy(downloaded, io.NewSectionReader(reader, clen, 16*bytesx.KiB))
		require.NoError(t, err)
		require.EqualValues(t, 16*bytesx.KiB, n)
		require.Equal(t, md5x.FormatUUID(digest), md5x.FormatUUID(downloaded))
	})

	t.Run("range read the 2nd 16 KiB block of the data", func(t *testing.T) {
		const (
			nlen = 128 * bytesx.KiB
			clen = 16 * bytesx.KiB
		)

		var ()

		md := library.NewMetadata(uuidx.WithSuffix(1), library.MetadataOptionEncryptionSeed(md5x.String(t.Name())))
		src, err := cryptox.NewReaderChaCha20(library.MetadataChaCha8(md), cryptox.NewChaCha8(t.Name()))
		require.NoError(t, err)

		routes := mux.NewRouter()
		routes.Handle("/m/{id}/download", alice.New().ThenFunc(download(src, nlen)))

		srv := httptest.NewServer(routes)
		defer srv.Close()

		c := &http.Client{}
		c.Transport = httpx.RewriteHostTransport(testx.Must(url.ParseRequestURI(srv.URL))(t), c.Transport)

		var (
			buf    bytes.Buffer
			digest = md5.New()
		)

		_n, err := io.Copy(&buf, io.LimitReader(cryptox.NewChaCha8(t.Name()), nlen))
		require.NoError(t, err)
		require.EqualValues(t, nlen, _n)
		require.EqualValues(t, nlen, len(buf.Bytes()))

		_n, err = io.Copy(digest, io.NewSectionReader(bytes.NewReader(buf.Bytes()), clen, clen))
		require.NoError(t, err)
		require.EqualValues(t, clen, _n)

		reader := library.NewDeeppoolReaderAt(c, md, testx.Must(blockcache.NewDirectoryCache(t.TempDir()))(t))

		downloaded := md5.New()
		n, err := io.Copy(downloaded, io.NewSectionReader(reader, clen, clen))
		require.NoError(t, err)
		require.EqualValues(t, clen, n)
		require.Equal(t, md5x.FormatUUID(digest), md5x.FormatUUID(downloaded))
	})
}
