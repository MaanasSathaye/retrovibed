package media

import (
	"log"
	"net/http"

	"github.com/Masterminds/squirrel"
	"github.com/go-playground/form/v4"
	"github.com/gorilla/mux"
	"github.com/justinas/alice"
	"github.com/retrovibed/retrovibed/httpauth"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/numericx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
)

type HTTPKnownOption func(*HTTPKnown)

func HTTPKnownOptionJWTSecret(j jwtx.SecretSource) HTTPKnownOption {
	return func(t *HTTPKnown) {
		t.jwtsecret = j
	}
}

func NewHTTPKnown(q sqlx.Queryer, options ...HTTPKnownOption) *HTTPKnown {
	svc := langx.Clone(HTTPKnown{
		q:         q,
		jwtsecret: env.JWTSecret,
		decoder:   formx.NewDecoder(),
		fts:       duckdbx.NewLucene(),
	}, options...)

	return &svc
}

type HTTPKnown struct {
	q         sqlx.Queryer
	jwtsecret jwtx.SecretSource
	decoder   *form.Decoder
	fts       lucenex.Driver
}

func (t *HTTPKnown) Bind(r *mux.Router) {
	r.StrictSlash(false)

	r.Path("/").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.search))

	r.Path("/{id}").Methods(http.MethodGet).Handler(alice.New(
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.find))
}

func (t *HTTPKnown) search(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		msg KnownSearchResponse = KnownSearchResponse{
			Next: &KnownSearchRequest{
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

	q := sqlx.Scan(library.KnownSearch(r.Context(), sqlx.Debug(t.q), library.KnownSearchBuilder().Where(squirrel.And{
		squirrel.Expr("1=1"),
		lucenex.Query(t.fts, msg.Next.Query, lucenex.WithDefaultField("title")),
	}).OrderBy("title DESC").Offset(msg.Next.Offset*msg.Next.Limit).Limit(msg.Next.Limit)))

	for v := range q.Iter() {
		tmp := langx.Clone(Known{}, KnownOptionFromLibraryKnown(langx.Clone(v, library.KnownOptionJSONSafeEncode)))
		msg.Items = append(msg.Items, &tmp)
	}

	if err = q.Err(); err != nil {
		log.Println(errorsx.Wrap(err, "encoding failed"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &msg); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPKnown) find(w http.ResponseWriter, r *http.Request) {
	var (
		meta library.Known
		id   = mux.Vars(r)["id"]
	)

	if err := library.KnownFindByID(r.Context(), t.q, id).Scan(&meta); sqlx.ErrNoRows(err) != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusNotFound))
		return
	} else if err != nil {
		log.Println(errorsx.Wrap(err, "unable to find metadata"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err := httpx.WriteJSON(w, httpx.GetBuffer(r), &KnownLookupResponse{
		Known: langx.Autoptr(
			langx.Clone(
				Known{},
				KnownOptionFromLibraryKnown(langx.Clone(meta, library.KnownOptionJSONSafeEncode)),
			),
		),
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}
