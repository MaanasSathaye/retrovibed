package media

import (
	"log"
	"net/http"
	"strings"

	"github.com/go-playground/form/v4"
	"github.com/gorilla/mux"
	"github.com/justinas/alice"
	"github.com/retrovibed/retrovibed/httpauth"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/numericx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

type HTTPKnownOption func(*HTTPKnown)

func HTTPKnownOptionJWTSecret(j jwtx.SecretSource) HTTPKnownOption {
	return func(t *HTTPKnown) {
		t.jwtsecret = j
	}
}

func NewHTTPKnown(q sqlx.Queryer, s fsx.Virtual, options ...HTTPKnownOption) *HTTPKnown {
	svc := langx.Clone(HTTPKnown{
		q:            q,
		jwtsecret:    env.JWTSecret,
		decoder:      formx.NewDecoder(),
		mediastorage: s,
		fts:          duckdbx.NewLucene(),
	}, options...)

	return &svc
}

type HTTPKnown struct {
	q            sqlx.Queryer
	jwtsecret    jwtx.SecretSource
	decoder      *form.Decoder
	mediastorage fsx.Virtual
	fts          lucenex.Driver
}

func (t *HTTPKnown) Bind(r *mux.Router) {
	r.StrictSlash(false)

	r.Path("/").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.search))

	r.Path("/match").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.match))

	r.Path("/{id}").Methods(http.MethodGet).Handler(alice.New(
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout10s(),
	).Then(http.FileServerFS(fsx.VirtualAsFSWithRewrite(t.mediastorage, func(s string) string {
		return strings.TrimPrefix(s, "m/")
	}))))
}

func (t *HTTPKnown) search(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		msg MediaSearchResponse = MediaSearchResponse{
			Next: &MediaSearchRequest{
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

	// ordering := "created_at DESC, description ASC"
	// if stringsx.Present(msg.Next.Query) {nownMetadata(langx.Clone(*p, library.MetadataOptionJSONSafeEncode)))
	// 	msg.Items = append(msg.Items, &tmp)
	// 	ordering = "description ASC"
	// }

	// q := library.MetadataSearchBuilder().Where(squirrel.And{
	// 	library.MetadataQueryVisible(),
	// 	lucenex.Query(t.fts, msg.Next.Query, lucenex.WithDefaultField("auto_description")),
	// }).OrderBy(ordering).Offset(msg.Next.Offset * msg.Next.Limit).Limit(msg.Next.Limit)

	// err = sqlxx.ScanEach(library.MetadataSearch(r.Context(), t.q, q), func(p *library.Metadata) error {
	// 	tmp := langx.Clone(Media{}, MediaOptionFromK
	// 	return nil
	// })

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

func (t *HTTPKnown) match(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		msg KnownMatchRequest = KnownMatchRequest{
			Query: "",
		}
	)

	if err = t.decoder.Decode(&msg, r.Form); err != nil {
		log.Println(errorsx.Wrap(err, "unable to decode request"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	// ordering := "created_at DESC, description ASC"
	// if stringsx.Present(msg.Next.Query) {nownMetadata(langx.Clone(*p, library.MetadataOptionJSONSafeEncode)))
	// 	msg.Items = append(msg.Items, &tmp)
	// 	ordering = "description ASC"
	// }

	// q := library.MetadataSearchBuilder().Where(squirrel.And{
	// 	library.MetadataQueryVisible(),
	// 	lucenex.Query(t.fts, msg.Next.Query, lucenex.WithDefaultField("auto_description")),
	// }).OrderBy(ordering).Offset(msg.Next.Offset * msg.Next.Limit).Limit(msg.Next.Limit)

	// err = sqlxx.ScanEach(library.MetadataSearch(r.Context(), t.q, q), func(p *library.Metadata) error {
	// 	tmp := langx.Clone(Media{}, MediaOptionFromK
	// 	return nil
	// })

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
