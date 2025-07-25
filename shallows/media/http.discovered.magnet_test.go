package media_test

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/davecgh/go-spew/spew"
	"github.com/gorilla/mux"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrenttestx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/tracking"
	"github.com/stretchr/testify/require"
)

func TestHTTPDiscoveredMagnet(t *testing.T) {
	t.Run("successfully creates a download from a magnet link", func(t *testing.T) {
		var (
			p      meta.Profile
			v      meta.Authz
			resp   *httptest.ResponseRecorder
			req    *http.Request
			result media.MagnetCreateResponse
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

		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(t.TempDir(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequestBytes(
			http.MethodPost,
			"/magnet",
			testx.Must(json.Marshal(&media.MagnetCreateRequest{Uri: "magnet:?xt=urn:btih:8665727372B28B0263690B82928399516641A1B4&dn=ubuntu-20.04.1-desktop-amd64.iso&tr=http%3A%2F%2Ftorrent.ubuntu.com%3A6969%2Fannounce"}))(t),
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusOK, resp.Result().StatusCode, spew.Sdump(resp.Result()))

		err = json.NewDecoder(resp.Result().Body).Decode(&result)
		require.NoError(t, err, spew.Sdump(resp.Result()))
		require.NotNil(t, result.Download)
		require.NotEmpty(t, result.Download.Media.Id)
		require.Equal(t, "ubuntu-20.04.1-desktop-amd64.iso", result.Download.Media.Description)

		var lmd tracking.Metadata
		err = tracking.MetadataFindByID(t.Context(), q, result.Download.Media.Id).Scan(&lmd)
		require.NoError(t, err)
		require.Equal(t, result.Download.Media.Id, lmd.ID)
		require.Equal(t, "ubuntu-20.04.1-desktop-amd64.iso", lmd.Description)
	})

	t.Run("returns bad request for invalid magnet URI", func(t *testing.T) {
		var (
			p    meta.Profile
			v    meta.Authz
			resp *httptest.ResponseRecorder
			req  *http.Request
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

		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(t.TempDir(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequestBytes(
			http.MethodPost,
			"/magnet",
			testx.Must(json.Marshal(&media.MagnetCreateRequest{Uri: "magnet:?xt=invalid_uri"}))(t),
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusBadRequest, resp.Result().StatusCode, spew.Sdump(resp.Result()))
	})

	t.Run("returns bad request for invalid JSON body", func(t *testing.T) {
		var (
			p    meta.Profile
			v    meta.Authz
			resp *httptest.ResponseRecorder
			req  *http.Request
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

		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(t.TempDir(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequestBytes(
			http.MethodPost,
			"/magnet",
			[]byte(`{"uri": "invalid`), // Malformed JSON
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusBadRequest, resp.Result().StatusCode, spew.Sdump(resp.Result()))
	})
}
