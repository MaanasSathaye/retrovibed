package media_test

import (
	"encoding/json"
	"net/http"
	"testing"

	"github.com/gorilla/mux"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/stretchr/testify/require"
)

func TestRSSFeedCreate(t *testing.T) {
	var (
		p      meta.Profile
		authz  meta.Authz
		result rss.FeedUpdateResponse
	)
	ctx, done := testx.Context(t)
	defer done()

	q := sqltestx.Metadatabase(t)
	defer q.Close()

	require.NoError(t, testx.Fake(&p, meta.ProfileOptionTestDefaults))
	require.NoError(t, meta.ProfileInsertWithDefaults(ctx, q, p).Scan(&p))
	require.NoError(t, testx.Fake(&authz, meta.AuthzOptionProfileID(p.ID), meta.AuthzOptionAdmin))
	require.NoError(t, meta.AuthzInsertWithDefaults(ctx, q, authz).Scan(&authz))

	routes := mux.NewRouter()

	media.NewHTTPRSSFeed(
		q,
		media.HTTPRSSFeedOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
	).Bind(routes.PathPrefix("/").Subrouter())

	encoded, err := json.Marshal(rss.FeedUpdateRequest{
		Feed: &rss.Feed{
			Url:          "https://example.com/71b9dbed-e985-42df-ba18-82dbf5779358",
			Description:  "hello world",
			Autodownload: true,
			Autoarchive:  true,
			Contributing: false,
		},
	})
	require.NoError(t, err)

	claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(authz)))

	resp, req, err := httptestx.BuildRequest(
		http.MethodPost,
		"/",
		encoded,
		httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
	)
	require.NoError(t, err)

	routes.ServeHTTP(resp, req)

	require.Equal(t, http.StatusOK, resp.Result().StatusCode)
	require.NoError(t, json.NewDecoder(resp.Body).Decode(&result))
	require.Equal(t, "d81f2387-d17a-cb19-cfb5-a1f3830589bd", result.Feed.Id)
	require.Equal(t, "hello world", result.Feed.Description)
	require.True(t, result.Feed.Autodownload)
	require.True(t, result.Feed.Autoarchive)
	require.False(t, result.Feed.Contributing)
}
