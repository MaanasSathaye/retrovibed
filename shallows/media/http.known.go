package media

import (
	"log"
	"net/http"

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

	r.Path("/{id}").Methods(http.MethodGet).Handler(alice.New(
		httpauth.AuthenticateWithToken(t.jwtsecret),
		// AuthzTokenHTTP(t.jwtsecret, AuthzPermUsermanagement),
		httpx.Timeout2s(),
	).ThenFunc(t.find))
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
