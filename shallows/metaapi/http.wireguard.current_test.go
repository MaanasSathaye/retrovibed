package metaapi_test

import (
	"encoding/json"
	"net/http"
	"os"
	"testing"

	"github.com/gofrs/uuid/v5"
	"github.com/golang-jwt/jwt/v5"
	"github.com/gorilla/mux"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/stretchr/testify/require"
)

func TestHTTPWireguardCurrent(t *testing.T) {
	var (
		result metaapi.WireguardCurrentResponse
		claims jwt.RegisteredClaims
	)

	ctx, done := testx.Context(t)
	defer done()

	tmpdir := fsx.DirVirtual(t.TempDir())
	path := testx.Must(uuid.NewV4())(t).String()
	require.NoError(t, os.WriteFile(tmpdir.Path(path), testx.IOBytes(testx.Read(testx.Fixture("wireguard", "example.1.conf"))), 0600))
	require.NoError(t, os.Symlink(tmpdir.Path(path), tmpdir.Path(wireguardx.Current)))

	routes := mux.NewRouter()

	metaapi.NewHTTPWireguard(
		tmpdir.Path(),
		metaapi.HTTPWireguardOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	claims = jwtx.NewJWTClaims(uuid.Nil.String(), jwtx.ClaimsOptionAuthnExpiration())

	resp, req, err := httptestx.BuildRequestContextBytes(ctx, http.MethodGet, "/current", nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.NoError(t, httpx.ErrorCode(resp.Result()))
	require.NoError(t, json.NewDecoder(resp.Body).Decode(&result))

	require.Equal(t, path, result.Wireguard.Id)
}

func TestHTTPWireguardCurrentZeroState(t *testing.T) {
	var (
		claims jwt.RegisteredClaims
	)

	ctx, done := testx.Context(t)
	defer done()

	tmpdir := fsx.DirVirtual(t.TempDir())

	routes := mux.NewRouter()

	metaapi.NewHTTPWireguard(
		tmpdir.Path(),
		metaapi.HTTPWireguardOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	claims = jwtx.NewJWTClaims(uuid.Nil.String(), jwtx.ClaimsOptionAuthnExpiration())

	resp, req, err := httptestx.BuildRequestContextBytes(ctx, http.MethodGet, "/current", nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.Error(t, httpx.ErrorCode(resp.Result()))
	require.Equal(t, http.StatusNotFound, resp.Code)
}
