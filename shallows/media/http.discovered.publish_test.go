package media_test

import (
	"bytes"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"

	"github.com/gofrs/uuid/v5"
	"github.com/gorilla/mux"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/james-lawrence/torrent/torrenttest"
	"github.com/retrovibed/retrovibed/httpauthtest"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httptestx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/sqltestx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/testx"
	"github.com/retrovibed/retrovibed/internal/torrenttestx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/stretchr/testify/require"
)

func TestDiscoveredPublishTorrent(t *testing.T) {
	t.Run("example 1 - successful case", func(t *testing.T) {
		var (
			p meta.Profile
			v meta.Authz
			r media.PublishedUploadResponse
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
		dvfs := fsx.DirVirtual(t.TempDir())
		routes := mux.NewRouter()

		media.NewHTTPDiscovered(
			q,
			tclient,
			storage.NewFile(dvfs.Path("torrent"), storage.FileOptionPathMakerInfohash),
			media.HTTPDiscoveredOptionJWTSecret(httpauthtest.UnsafeJWTSecretSource),
			media.HTTPDiscoveredOptionRootStorage(dvfs),
		).Bind(routes.PathPrefix("/").Subrouter())

		info, err := torrenttest.RandomMulti(vfs.Path(), 5, 128*bytesx.KiB, bytesx.MiB, metainfo.OptionPieceLength(bytesx.MiB))
		require.NoError(t, err)

		md, err := torrent.NewFromInfo(info, torrent.OptionStorage(storage.NewFile(vfs.Path())), torrent.OptionDisplayName(info.Name))
		require.NoError(t, err)

		mimetype, buf, err := media.PublishRequest(ctx, md, &media.PublishedUploadRequest{
			Entropy:  uuidx.WithSuffix(16),
			Mimetype: mimex.RetrovibedMediaArchive,
		})
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
		require.NoError(t, json.NewDecoder(resp.Body).Decode(&r))
		require.Equal(t, info.Name, r.Published.Description)
		require.Equal(t, md.ID.String(), r.Published.Id)
		require.Equal(t, mimex.RetrovibedMediaArchive, r.Published.Mimetype)
		require.Equal(t, 1, testx.Must(sqlx.Count(ctx, q, "SELECT COUNT(*) FROM torrents_metadata"))(t))
		require.Equal(t, md5x.FormatUUID(md5x.Digest(md.ID.Bytes(), uuid.FromStringOrNil(uuidx.WithSuffix(16)).Bytes())), testx.Must(sqlx.String(ctx, q, "SELECT encryption_seed::text FROM torrents_metadata"))(t))
		require.Equal(t, "", testx.Must(sqlx.String(ctx, q, "SELECT tracker FROM torrents_metadata"))(t))
		require.Equal(t, mimex.RetrovibedMediaArchive, testx.Must(sqlx.String(ctx, q, "SELECT mimetype FROM torrents_metadata"))(t))
		require.EqualValues(t, info.TotalLength(), testx.Must(sqlx.Value[int](ctx, q, "SELECT bytes FROM torrents_metadata"))(t))
		require.EqualValues(t, info.TotalLength(), testx.Must(sqlx.Value[int](ctx, q, "SELECT downloaded FROM torrents_metadata"))(t))
		require.True(t, testx.Must(sqlx.Value[bool](ctx, q, "SELECT seeding FROM torrents_metadata"))(t))

		path := dvfs.Path("torrent", md.ID.String())
		require.DirExists(t, path)
		require.FileExists(t, fmt.Sprintf("%s.torrent", path))
		require.Equal(t, testx.IOMD5(bytes.NewReader(errorsx.Must(metainfo.Encode(md.Metainfo())))), testx.ReadMD5(fmt.Sprintf("%s.torrent", path)))
	})
}
