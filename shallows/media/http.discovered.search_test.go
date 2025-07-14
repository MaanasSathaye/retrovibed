package media_test

import (
	"encoding/json"
	"fmt"
	"net/http"
	"testing"
	"time"

	"github.com/gorilla/mux"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/fsx"
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

func TestDiscoveredSearch(t *testing.T) {
	t.Run("standard search", func(t *testing.T) {
		// ensure that search doesnt return an error.
		var (
			p  meta.Profile
			v  meta.Authz
			md tracking.Metadata
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
		require.NoError(t, testx.Fake(&md, tracking.MetadataOptionTestDefaults))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, md).Scan(&md))

		vfs := fsx.DirVirtual(t.TempDir())

		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(vfs.Path(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		encoder := formx.NewEncoder()
		query, err := encoder.Encode(media.MediaSearchRequest{
			Limit: 100,
			Query: "derp",
		})
		require.NoError(t, err)

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequest(
			http.MethodGet,
			fmt.Sprintf("/available?%s", query.Encode()),
			nil,
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusOK, resp.Result().StatusCode)
	})

	t.Run("filter by query", func(t *testing.T) {
		var (
			p         meta.Profile
			v         meta.Authz
			mdMatch   tracking.Metadata
			mdNoMatch tracking.Metadata
			result    media.DownloadSearchResponse
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

		// Metadata that should match the query
		require.NoError(t, testx.Fake(&mdMatch,
			tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(100),
			tracking.MetadataOptionDownloaded(50),
			tracking.MetadataOptionDescription("unique_query_term_video"),
			func(t *tracking.Metadata) { t.InitiatedAt = time.Now() },
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdMatch).Scan(&mdMatch))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, mdMatch.ID).Scan(&mdMatch))

		// Metadata that should NOT match the query
		require.NoError(t, testx.Fake(&mdNoMatch,
			tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(100),
			tracking.MetadataOptionDownloaded(50),
			tracking.MetadataOptionDescription("another_item_audio"),
			func(t *tracking.Metadata) { t.InitiatedAt = time.Now() },
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdNoMatch).Scan(&mdNoMatch))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, mdNoMatch.ID).Scan(&mdNoMatch))

		vfs := fsx.DirVirtual(t.TempDir())
		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(vfs.Path(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		encoder := formx.NewEncoder()

		// Request with a specific query
		query, err := encoder.Encode(media.DownloadSearchRequest{
			Limit: 100,
			Query: "unique_query_term",
		})
		require.NoError(t, err)

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequest(
			http.MethodGet,
			fmt.Sprintf("/available?%s", query.Encode()),
			nil,
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusOK, resp.Result().StatusCode)

		err = json.NewDecoder(resp.Result().Body).Decode(&result)
		require.NoError(t, err)

		require.Len(t, result.Items, 2, "Expected 2 metadata items (both initiated and incomplete) in the search results")
		require.Equal(t, mdMatch.ID, result.Items[0].Media.Id, "Expected item to match the query")
	})

	t.Run("filter by completed=true", func(t *testing.T) {
		var (
			p            meta.Profile
			v            meta.Authz
			mdIncomplete tracking.Metadata
			mdCompleted  tracking.Metadata
			result       media.DownloadSearchResponse
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

		require.NoError(t, testx.Fake(&mdIncomplete,
			tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(100),
			tracking.MetadataOptionDownloaded(50),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdIncomplete).Scan(&mdIncomplete))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, mdIncomplete.ID).Scan(&mdIncomplete))

		require.NoError(t, testx.Fake(&mdCompleted,
			tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(100),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdCompleted).Scan(&mdCompleted))
		require.NoError(t, tracking.MetadataCompleteByID(ctx, q, mdCompleted.ID, 0, mdCompleted.Bytes, 0).Scan(&mdCompleted))
		require.EqualValues(t, mdCompleted.Bytes, mdCompleted.Downloaded)

		vfs := fsx.DirVirtual(t.TempDir())
		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(vfs.Path(), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
		).Bind(routes.PathPrefix("/").Subrouter())

		encoder := formx.NewEncoder()

		query, err := encoder.Encode(media.DownloadSearchRequest{
			Limit:     100,
			Completed: true,
		})
		require.NoError(t, err)

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequest(
			http.MethodGet,
			fmt.Sprintf("/available?%s", query.Encode()),
			nil,
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusOK, resp.Result().StatusCode)

		err = json.NewDecoder(resp.Result().Body).Decode(&result)
		require.NoError(t, err)

		require.Len(t, result.Items, 1, "Expected only 1 incomplete metadata item in the search results")
		require.Equal(t, mdCompleted.ID, result.Items[0].Media.Id, "Expected the completed item to be returned")
	})
}
