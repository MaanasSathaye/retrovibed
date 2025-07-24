package media_test

import (
	"net/http"
	"testing"

	"github.com/gorilla/mux"
	"github.com/james-lawrence/torrent/storage"
	"github.com/james-lawrence/torrent/torrenttest"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrenttestx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/tracking"
	"github.com/stretchr/testify/require"
)

func TestDiscoveredPublishTorrent(t *testing.T) {
	var (
		p meta.Profile
		v meta.Authz
	)
	ctx, done := testx.Context(t)
	defer done()

	q := sqltestx.Metadatabase(t)
	defer q.Close()

	tclient := torrenttestx.QuickClient(t)

	require.NoError(t, testx.Fake(&p, meta.ProfileOptionTestDefaults))
	require.NoError(t, meta.ProfileInsertWithDefaults(ctx, q, p).Scan(&p))
	require.NoError(t, testx.Fake(&v, meta.AuthzOptionProfileID(p.ID), meta.AuthzOptionAdmin))
	require.NoError(t, meta.AuthzInsertWithDefaults(ctx, q, v).Scan(&v))

	vfs := fsx.DirVirtual(t.TempDir())

	routes := mux.NewRouter()

	media.NewHTTPDiscovered(
		q,
		tclient,
		storage.NewFile(vfs.Path(), storage.FileOptionPathMakerInfohash),
		media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	tmpdir := t.TempDir()
	info, err := torrenttest.RandomMulti(tmpdir, 5, 128*bytesx.KiB, bytesx.MiB)
	require.NoError(t, err)
	_ = info

	mimetype, buf, err := tracking.PublishRequest(ctx, tmpdir)
	require.NoError(t, err)

	claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

	resp, req, err := httptestx.BuildRequestContext(
		ctx,
		http.MethodPost,
		"/publish",
		buf,
		httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		httptestx.RequestOptionHeader("Content-Type", mimetype),
	)
	require.NoError(t, err)

	require.Equal(t, 0, testx.Must(sqlx.Count(ctx, q, "SELECT COUNT(*) FROM torrents_metadata"))(t))

	routes.ServeHTTP(resp, req)
	require.NoError(t, buf.Close())

	require.Equal(t, http.StatusOK, resp.Result().StatusCode)
	require.Equal(t, 1, testx.Must(sqlx.Count(ctx, q, "SELECT COUNT(*) FROM torrents_metadata"))(t))
	require.Equal(t, "https://example.com/announce", testx.Must(sqlx.String(ctx, q, "SELECT tracker FROM torrents_metadata"))(t))
}
