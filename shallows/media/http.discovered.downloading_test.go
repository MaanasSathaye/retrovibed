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

func TestDiscoveredDownloading(t *testing.T) {
	t.Run("order by download percentage and fully downloaded status", func(t *testing.T) {
		var (
			p       meta.Profile
			v       meta.Authz
			md50    tracking.Metadata // 50% downloaded
			md90    tracking.Metadata // 90% downloaded
			md70    tracking.Metadata // 70% downloaded
			mdFull1 tracking.Metadata // 100% downloaded
			mdFull2 tracking.Metadata // 100% downloaded
			md10    tracking.Metadata // 10% downloaded
			result  media.DownloadSearchResponse
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

		require.NoError(t, testx.Fake(&md90,
			tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(1000),
			tracking.MetadataOptionDownloaded(900), // 90%
			tracking.MetadataOptionDescription("derp 90 download"),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, md90).Scan(&md90))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, md90.ID).Scan(&md90))

		require.NoError(t, testx.Fake(&md70, tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(100),
			tracking.MetadataOptionDownloaded(70), // 70%
			tracking.MetadataOptionDescription("derp 70 download"),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, md70).Scan(&md70))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, md70.ID).Scan(&md70))

		require.NoError(t,
			testx.Fake(
				&md50,
				tracking.MetadataOptionTestDefaults,
				tracking.MetadataOptionBytes(60),
				tracking.MetadataOptionDownloaded(30), // 50%
				tracking.MetadataOptionDescription("derp 50 download"),
			))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, md50).Scan(&md50))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, md50.ID).Scan(&md50))

		require.NoError(t, testx.Fake(&md10, tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(10),
			tracking.MetadataOptionDownloaded(1), // 10%
			tracking.MetadataOptionDescription("derp 10 download"),
			func(t *tracking.Metadata) {
				t.InitiatedAt = time.Now()
			},
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, md10).Scan(&md10))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, md10.ID).Scan(&md10))

		require.NoError(t, testx.Fake(&mdFull1, tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(1234),
			tracking.MetadataOptionDownloaded(1234), // 100%
			tracking.MetadataOptionDescription("derp Full1 download"),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdFull1).Scan(&mdFull1))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, mdFull1.ID).Scan(&mdFull1))

		require.NoError(t, testx.Fake(&mdFull2, tracking.MetadataOptionTestDefaults,
			tracking.MetadataOptionBytes(2000),      // Different total size for full download
			tracking.MetadataOptionDownloaded(2000), // 100%
			tracking.MetadataOptionDescription("derp Full2 download"),
		))
		require.NoError(t, tracking.MetadataInsertWithDefaults(ctx, q, mdFull2).Scan(&mdFull2))
		require.NoError(t, tracking.MetadataDownloadByID(ctx, q, mdFull2.ID).Scan(&mdFull2))

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
			Limit: 100,
			Query: "derp",
		})
		require.NoError(t, err)

		claims := metaapi.NewJWTClaim(metaapi.TokenFromRegisterClaims(jwtx.NewJWTClaims(p.ID, jwtx.ClaimsOptionAuthnExpiration()), metaapi.TokenOptionFromAuthz(v)))

		resp, req, err := httptestx.BuildRequest(
			http.MethodGet,
			fmt.Sprintf("/downloading?%s", query.Encode()),
			nil,
			httptestx.RequestOptionAuthorization(httpauthtest.UnsafeClaimsToken(claims, httpauthtest.UnsafeJWTSecretSource)),
		)
		require.NoError(t, err)

		routes.ServeHTTP(resp, req)

		require.Equal(t, http.StatusOK, resp.Result().StatusCode)

		err = json.NewDecoder(resp.Result().Body).Decode(&result)
		require.NoError(t, err)
		require.Len(t, result.Items, 6, "Expected 6 metadata items in the search results")

		// Verify the order - Inlined checks
		// Partially downloaded items
		require.Equal(t, md90.ID, result.Items[0].Media.Id, fmt.Sprintf("Expected %s at position %d", md90.ID, 0))
		require.Equal(t, md90.Downloaded, result.Items[0].Downloaded)
		require.Equal(t, md90.Bytes, result.Items[0].Bytes)

		require.Equal(t, md70.ID, result.Items[1].Media.Id, fmt.Sprintf("Expected %s at position %d", md70.ID, 1))

		require.Equal(t, md50.ID, result.Items[2].Media.Id, fmt.Sprintf("Expected %s at position %d", md50.ID, 2))

		require.Equal(t, md10.ID, result.Items[3].Media.Id, fmt.Sprintf("Expected %s at position %d", md10.ID, 3))

		// Fully downloaded items (order between them doesn't matter, just that they are last)
		require.True(t, result.Items[4].Media.Id == mdFull1.ID || result.Items[4].Media.Id == mdFull2.ID, fmt.Sprintf("Expected a fully downloaded item at position %d", 4))

		require.True(t, result.Items[5].Media.Id == mdFull1.ID || result.Items[5].Media.Id == mdFull2.ID, fmt.Sprintf("Expected a fully downloaded item at position %d", 5))

		require.NotEqual(t, result.Items[4].Media.Id, result.Items[5].Media.Id, "Expected two different fully downloaded items at the end")
	})
}
