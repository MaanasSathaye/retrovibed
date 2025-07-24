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
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/stretchr/testify/require"
)

func TestHTTPWireguardSearchZeroState(t *testing.T) {
	var (
		result metaapi.WireguardSearchResponse
		claims jwt.RegisteredClaims
	)

	ctx, done := testx.Context(t)
	defer done()

	tmpdir := fsx.DirVirtual(t.TempDir())

	routes := mux.NewRouter()

	metaapi.NewHTTPWireguard(
		tmpdir.Path("does.not.exist"),
		metaapi.HTTPWireguardOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	b := testx.Must(formx.NewEncoder().Encode(&metaapi.WireguardSearchRequest{
		Offset: 0,
	}))(t)

	claims = jwtx.NewJWTClaims(uuid.Nil.String(), jwtx.ClaimsOptionAuthnExpiration())

	resp, req, err := httptestx.BuildRequestContextBytes(ctx, http.MethodGet, "/?"+b.Encode(), nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.NoError(t, httpx.ErrorCode(resp.Result()))
	require.NoError(t, json.NewDecoder(resp.Body).Decode(&result))

	require.Equal(t, len(result.Items), 0)
}

func TestHTTPWireguardSearch(t *testing.T) {
	var (
		result metaapi.WireguardSearchResponse
		claims jwt.RegisteredClaims
	)

	ctx, done := testx.Context(t)
	defer done()

	tmpdir := fsx.DirVirtual(t.TempDir())
	path := testx.Must(uuid.NewV4())(t).String()
	d, err := os.Create(tmpdir.Path(path))
	require.NoError(t, err)
	require.NoError(t, d.Close())

	routes := mux.NewRouter()

	metaapi.NewHTTPWireguard(
		tmpdir.Path(),
		metaapi.HTTPWireguardOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	b := testx.Must(formx.NewEncoder().Encode(&metaapi.WireguardSearchRequest{
		Offset: 0,
	}))(t)

	claims = jwtx.NewJWTClaims(uuid.Nil.String(), jwtx.ClaimsOptionAuthnExpiration())

	resp, req, err := httptestx.BuildRequestContextBytes(ctx, http.MethodGet, "/?"+b.Encode(), nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.NoError(t, httpx.ErrorCode(resp.Result()))
	require.NoError(t, json.NewDecoder(resp.Body).Decode(&result))

	require.Equal(t, len(result.Items), 1)
	require.Equal(t, result.Items[0].Id, path)
}
