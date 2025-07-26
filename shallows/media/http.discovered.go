package media

import (
	"bytes"
	"context"
	"crypto/md5"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"mime/multipart"
	"net/http"
	"os"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/go-playground/form/v4"
	"github.com/gofrs/uuid/v5"
	"github.com/gorilla/mux"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/justinas/alice"
	"github.com/retrovibed/retrovibed/httpauth"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/iox"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/numericx"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/sqlxx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/tracking"
)

type HTTPDiscoveredOption func(*HTTPDiscovered)

func HTTPDiscoveredOptionJWTSecret(j jwtx.SecretSource) HTTPDiscoveredOption {
	return func(t *HTTPDiscovered) {
		t.jwtsecret = j
	}
}

func HTTPDiscoveredOptionRootStorage(vfs fsx.Virtual) HTTPDiscoveredOption {
	return func(t *HTTPDiscovered) {
		t.rootstorage = vfs
	}
}

type download interface {
	Start(t torrent.Metadata, options ...torrent.Tuner) (dl torrent.Torrent, added bool, err error)
	Stop(t torrent.Metadata) (err error)
}

func NewHTTPDiscovered(q sqlx.Queryer, d download, c storage.ClientImpl, options ...HTTPDiscoveredOption) *HTTPDiscovered {
	svc := langx.Clone(HTTPDiscovered{
		q:           q,
		d:           d,
		c:           c,
		jwtsecret:   env.JWTSecret,
		decoder:     formx.NewDecoder(),
		rootstorage: fsx.DirVirtual(os.TempDir()),
		fts:         duckdbx.NewLucene(),
	}, options...)

	return &svc
}

type HTTPDiscovered struct {
	q           sqlx.Queryer
	d           download
	c           storage.ClientImpl
	jwtsecret   jwtx.SecretSource
	decoder     *form.Decoder
	rootstorage fsx.Virtual
	fts         lucenex.Driver
}

func (t *HTTPDiscovered) Bind(r *mux.Router) {
	r.StrictSlash(false)

	r.Path("/").Methods(http.MethodPost).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.TimeoutRollingWrite(3*time.Second),
	).ThenFunc(t.upload))

	r.Path("/publish").Methods(http.MethodPost).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.TimeoutRollingWrite(3*time.Second),
	).ThenFunc(t.publish))

	r.Path("/magnet").Methods(http.MethodPost).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.Timeout2s(),
	).ThenFunc(t.magnet))

	r.Path("/available").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.search))

	r.Path("/downloading").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.downloading))

	r.Path("/{id}").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.metadata))

	r.Path("/{id}").Methods(http.MethodPost).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.download))

	r.Path("/{id}").Methods(http.MethodDelete).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.pause))
}

func (t *HTTPDiscovered) magnet(w http.ResponseWriter, r *http.Request) {
	var (
		msg MagnetCreateRequest
		dl  torrent.Torrent
	)

	if err := json.NewDecoder(r.Body).Decode(&msg); err != nil {
		log.Println(errorsx.Wrap(err, "unable to parse magnet link request"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	m, err := metainfo.ParseMagnetURI(msg.Uri)
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to parse magnet link"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	lmd := tracking.NewMetadata(
		langx.Autoptr(m.InfoHash),
		tracking.MetadataOptionFromMagnet(&m),
		tracking.MetadataOptionTrackers(m.Trackers...),
		tracking.MetadataOptionAutoDescription,
	)

	if err = tracking.MetadataInsertWithDefaults(r.Context(), t.q, lmd).Scan(&lmd); err != nil {
		log.Println(errorsx.Wrap(err, "unable to record metadata record"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	metadata, err := torrent.New(metainfo.Hash(lmd.Infohash), torrent.OptionStorage(t.c), torrentx.OptionTracker(lmd.Tracker), torrent.OptionPublicTrackers(lmd.Private, tracking.PublicTrackers()...))
	if err != nil {
		log.Println(errorsx.Wrapf(err, "unable to create torrent from metadata %s", lmd.ID))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if dl, _, err = t.d.Start(metadata); err != nil {
		log.Println(errorsx.Wrap(err, "unable to start download"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	go func() {
		errorsx.Log(tracking.Download(context.Background(), t.q, t.rootstorage, &lmd, dl))
	}()

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &MagnetCreateResponse{
		Download: langx.Autoptr(
			langx.Clone(
				Download{},
				DownloadOptionFromTorrentMetadata(lmd),
			),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) publish(w http.ResponseWriter, r *http.Request) {
	var (
		err     error
		decoded PublishedUploadRequest
		copied  = &iox.Copied{Result: new(uint64)}
		mhash   = md5.New()
		buf     bytes.Buffer
	)

	reader, err := r.MultipartReader()
	if err != nil {
		log.Println(errorsx.Wrap(err, "failed creating a multipart form"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	torfile, err := reader.NextPart()
	if err != nil {
		log.Println(errorsx.Wrap(err, "missing torrent file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	defer torfile.Close()

	// we limit torrent files to 128 MB for sanity sake.
	meta, err := metainfo.Load(io.TeeReader(io.LimitReader(torfile, 128*bytesx.MiB), io.MultiWriter(&buf, mhash, copied)))
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to read torrent file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusRequestEntityTooLarge))
		return
	}

	info, err := meta.UnmarshalInfo()
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to read torrent info"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	torimp, err := t.c.OpenTorrent(&info, meta.ID().AsByteArray())
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to open torrent storage"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	contents, err := reader.NextPart()
	if err != nil {
		log.Println(errorsx.Wrap(err, "missing torrent contents"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	defer contents.Close()

	n, err := io.Copy(io.NewOffsetWriter(torimp, 0), contents)
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to copy torrent to storage"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if n != info.TotalLength() {
		log.Println(errorsx.Errorf("failed to upload all content %d != %d", n, info.TotalLength()))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err := os.WriteFile(t.rootstorage.Path(fmt.Sprintf("%s.torrent", meta.ID().String())), buf.Bytes(), 0600); err != nil {
		log.Println(errorsx.Errorf("failed to write torrent file %d != %d", n, info.TotalLength()))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	metadata, err := reader.NextPart()
	if err != nil {
		log.Println(errorsx.Wrap(err, "missing metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	defer metadata.Close()

	if err = json.NewDecoder(metadata).Decode(&decoded); err != nil {
		log.Println(errorsx.Wrap(err, "invalid metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	lmd := tracking.NewMetadata(
		langx.Autoptr(meta.HashInfoBytes()),
		tracking.MetadataOptionFromInfo(&info),
		tracking.MetadataOptionDownloaded(n),
		tracking.MetadataOptionTrackers(slicesx.Flatten(meta.UpvertedAnnounceList()...)...),
		tracking.MetadataOptionEntropySeed(meta.ID().Bytes(), uuid.FromStringOrNil(decoded.Entropy).Bytes()),
		tracking.MetadataOptionMimetype(decoded.Mimetype),
		tracking.MetadataOptionAutoSeeding,
		tracking.MetadataOptionAutoDescription,
	)

	if err = tracking.MetadataInsertWithDefaults(r.Context(), t.q, lmd).Scan(&lmd); err != nil {
		log.Println(errorsx.Wrap(err, "unable to record metadata record"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &PublishedUploadResponse{
		Published: langx.Autoptr(
			langx.Clone(
				Published{},
				PublishedOptionFromTorrentMetadata(lmd),
			),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) upload(w http.ResponseWriter, r *http.Request) {
	var (
		err    error
		dl     torrent.Torrent
		f      multipart.File
		fh     *multipart.FileHeader
		buf    [bytesx.MiB]byte
		copied = &iox.Copied{Result: new(uint64)}
		mhash  = md5.New()
	)

	if f, fh, err = r.FormFile("content"); err != nil {
		log.Println(errorsx.Wrap(err, "content parameter required"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	defer f.Close()

	tmp, err := fsx.CreateTemp(t.rootstorage, "retrovibed.upload.*")
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to create temporary file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}
	defer func() {
		if err == nil {
			return
		}

		log.Println("failure receiving upload, removing attempt", err)
		errorsx.Log(errorsx.Wrap(os.Remove(tmp.Name()), "unable to remove tmp"))
	}()
	defer tmp.Close()

	if _, err = io.CopyBuffer(io.MultiWriter(tmp, mhash, copied), f, buf[:]); err != nil {
		log.Println(errorsx.Wrap(err, "unable to create temporary file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	meta, err := metainfo.LoadFromFile(tmp.Name())
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to read temporary file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if info, err := meta.UnmarshalInfo(); err == nil && !langx.Autoderef(info.Private) {
		meta.AnnounceList = append(meta.AnnounceList, tracking.PublicTrackers())
	}

	info, err := meta.UnmarshalInfo()
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to read temporary file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}
	info.Name = fh.Filename

	lmd := tracking.NewMetadata(
		langx.Autoptr(meta.HashInfoBytes()),
		tracking.MetadataOptionFromInfo(&info),
		tracking.MetadataOptionTrackers(slicesx.Flatten(meta.UpvertedAnnounceList()...)...),
		tracking.MetadataOptionAutoDescription,
	)

	if err = tracking.MetadataInsertWithDefaults(r.Context(), t.q, lmd).Scan(&lmd); err != nil {
		log.Println(errorsx.Wrap(err, "unable to record metadata record"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = os.Rename(tmp.Name(), t.rootstorage.Path(fmt.Sprintf("%s.torrent", metainfo.Hash(lmd.Infohash).String()))); err != nil {
		log.Println(errorsx.Wrap(err, "unable to failed to record torrent file"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	metadata, err := torrent.New(
		metainfo.Hash(lmd.Infohash),
		torrent.OptionStorage(t.c),
		torrent.OptionNodes(meta.NodeList()...),
		torrentx.OptionTracker(lmd.Tracker),
		torrent.OptionWebseeds(meta.UrlList),
		torrent.OptionPublicTrackers(lmd.Private, tracking.PublicTrackers()...),
	)
	if err != nil {
		log.Println(errorsx.Wrapf(err, "unable to create torrent from metadata %s", lmd.ID))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if dl, _, err = t.d.Start(metadata); err != nil {
		log.Println(errorsx.Wrap(err, "unable to start download"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	go func() {
		errorsx.Log(tracking.Download(context.Background(), t.q, t.rootstorage, &lmd, dl))
	}()

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &MediaUploadResponse{
		Media: langx.Autoptr(
			langx.Clone(
				Media{},
				MediaOptionFromTorrentMetadata(lmd),
			),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) pause(w http.ResponseWriter, r *http.Request) {
	var (
		md tracking.Metadata
		id = mux.Vars(r)["id"]
	)

	if err := tracking.MetadataFindByID(r.Context(), t.q, id).Scan(&md); sqlx.ErrNoRows(err) != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusNotFound))
		return
	} else if err != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	metadata, err := torrent.New(metainfo.Hash(md.Infohash), torrent.OptionStorage(t.c))
	if err != nil {
		log.Println(errorsx.Wrapf(err, "unable to create metadata from metadata %s", md.ID))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = t.d.Stop(metadata); err != nil {
		log.Println(errorsx.Wrap(err, "unable to stop download"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = tracking.MetadataPausedByID(r.Context(), t.q, id).Scan(&md); err != nil {
		log.Println(errorsx.Wrap(err, "unable to pause metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &DownloadBeginResponse{
		Download: langx.Autoptr(
			langx.Clone(
				Download{},
				DownloadOptionFromTorrentMetadata(langx.Clone(md, tracking.MetadataOptionJSONSafeEncode))),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) download(w http.ResponseWriter, r *http.Request) {
	var (
		meta  tracking.Metadata
		id    = mux.Vars(r)["id"]
		dl    torrent.Torrent
		added bool
	)

	if err := tracking.MetadataFindByID(r.Context(), t.q, id).Scan(&meta); sqlx.ErrNoRows(err) != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusNotFound))
		return
	} else if err != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	metadata, err := torrent.New(
		metainfo.Hash(meta.Infohash),
		torrent.OptionStorage(t.c),
		torrent.OptionTrackers(meta.Tracker),
		torrent.OptionPublicTrackers(meta.Private, tracking.PublicTrackers()...),
	)
	if err != nil {
		log.Println(errorsx.Wrapf(err, "unable to create metadata from metadata %s", meta.ID))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if dl, added, err = t.d.Start(metadata); err != nil {
		log.Println(errorsx.Wrap(err, "unable to start download"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if added {
		go func() {
			errorsx.Log(tracking.Download(context.Background(), t.q, t.rootstorage, &meta, dl))
		}()
	}

	if err := tracking.MetadataDownloadByID(r.Context(), t.q, id).Scan(&meta); err != nil {
		log.Println(errorsx.Wrap(err, "unable to track download"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &DownloadBeginResponse{
		Download: langx.Autoptr(
			langx.Clone(
				Download{},
				DownloadOptionFromTorrentMetadata(langx.Clone(meta, tracking.MetadataOptionJSONSafeEncode))),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) metadata(w http.ResponseWriter, r *http.Request) {
	var (
		meta tracking.Metadata
		id   = mux.Vars(r)["id"]
	)

	if err := tracking.MetadataFindByID(r.Context(), t.q, id).Scan(&meta); sqlx.ErrNoRows(err) != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusNotFound))
		return
	} else if err != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &DownloadMetadataResponse{
		Download: langx.Autoptr(
			langx.Clone(
				Download{},
				DownloadOptionFromTorrentMetadata(langx.Clone(meta, tracking.MetadataOptionJSONSafeEncode))),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) downloading(w http.ResponseWriter, r *http.Request) {
	var (
		msg DownloadSearchResponse = DownloadSearchResponse{
			Next: &DownloadSearchRequest{
				Limit: 100,
			},
		}
	)

	if err := t.decoder.Decode(msg.Next, r.Form); err != nil {
		log.Println(errorsx.Wrap(err, "unable to decode request"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	msg.Next.Limit = numericx.Min(msg.Next.Limit, 100)

	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQueryInitiated(),
			tracking.MetadataQueryIncomplete(),
			tracking.MetadataQueryNotPaused(),
		},
	).OrderBy("peers > 0 DESC, downloaded < bytes DESC, downloaded/bytes DESC").Offset(msg.Next.Offset * msg.Next.Limit).Limit(msg.Next.Limit)

	qq := sqlx.Scan(tracking.MetadataSearch(r.Context(), t.q, q))
	for p := range qq.Iter() {
		tmp := langx.Clone(Download{}, DownloadOptionFromTorrentMetadata(langx.Clone(p, tracking.MetadataOptionJSONSafeEncode)))
		msg.Items = append(msg.Items, &tmp)
	}

	if err := qq.Err(); err != nil {
		log.Println(errorsx.Wrap(err, "encoding failed"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &msg); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPDiscovered) search(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		msg DownloadSearchResponse = DownloadSearchResponse{
			Next: &DownloadSearchRequest{
				Limit: 100,
			},
		}
	)

	if err = t.decoder.Decode(msg.Next, r.Form); err != nil {
		log.Println(errorsx.Wrap(err, "unable to decode request"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	msg.Next.Limit = numericx.Min(msg.Next.Limit, 100)

	q := tracking.MetadataSearchBuilder().Where(squirrel.And{
		tracking.MetadataQueryCompleted(msg.Next.Completed),
		lucenex.Query(t.fts, msg.Next.Query, lucenex.WithDefaultField("auto_description")),
	}).OrderBy("created_at DESC").Offset(msg.Next.Offset * msg.Next.Limit).Limit(msg.Next.Limit)

	err = sqlxx.ScanEach(tracking.MetadataSearch(r.Context(), t.q, q), func(p *tracking.Metadata) error {
		tmp := langx.Clone(Download{}, DownloadOptionFromTorrentMetadata(langx.Clone(*p, tracking.MetadataOptionJSONSafeEncode)))
		msg.Items = append(msg.Items, &tmp)
		return nil
	})

	if err != nil {
		log.Println(errorsx.Wrap(err, "encoding failed"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &msg); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}
