package metaapi_test

import (
	"fmt"
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
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/stretchr/testify/require"
)

func TestHTTPWireguardTouch(t *testing.T) {
	var (
		claims jwt.RegisteredClaims
	)

	ctx, done := testx.Context(t)
	defer done()

	tmpdir := fsx.DirVirtual(t.TempDir())

	path1 := testx.Must(uuid.NewV4())(t).String()
	d, err := os.Create(tmpdir.Path(path1))
	require.NoError(t, err)
	require.NoError(t, d.Close())

	routes := mux.NewRouter()

	metaapi.NewHTTPWireguard(
		tmpdir.Path(),
		metaapi.HTTPWireguardOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	claims = jwtx.NewJWTClaims(uuid.Nil.String(), jwtx.ClaimsOptionAuthnExpiration())

	resp, req, err := httptestx.BuildRequestContext(ctx, http.MethodPut, fmt.Sprintf("/%s", path1), nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.NoError(t, httpx.ErrorCode(resp.Result()))

	resp, req, err = httptestx.BuildRequestContext(ctx, http.MethodPut, fmt.Sprintf("/%s", path1), nil, httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(&claims, httpauthtest.UnsafeJWTSecretSource)))
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)
	require.NoError(t, httpx.ErrorCode(resp.Result()))
}
