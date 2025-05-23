package metaapi

import (
	"crypto/md5"
	"io"
	"io/fs"
	"log"
	"mime/multipart"
	"net/http"
	"os"

	"github.com/go-playground/form/v4"
	"github.com/gorilla/mux"
	"github.com/justinas/alice"
	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/httpauth"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/formx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/iox"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/numericx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
)

type HTTPWireguardOption func(*HTTPWireguard)

func HTTPWireguardOptionJWTSecret(j jwtx.SecretSource) HTTPWireguardOption {
	return func(t *HTTPWireguard) {
		t.jwtsecret = j
	}
}

func NewHTTPWireguard(dir string, options ...HTTPWireguardOption) *HTTPWireguard {
	svc := langx.Clone(HTTPWireguard{
		dir:       fsx.DirVirtual(dir),
		jwtsecret: authn.JWTSecretFromEnv,
		decoder:   formx.NewDecoder(),
	}, options...)

	return &svc
}

type HTTPWireguard struct {
	dir       fsx.Virtual
	jwtsecret jwtx.SecretSource
	decoder   *form.Decoder
}

func (t *HTTPWireguard) Bind(r *mux.Router) {
	r.StrictSlash(false)
	// r.Use(httpx.DebugRequest)

	r.Path("/").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpx.ParseForm,
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.search))

	r.Path("/").Methods(http.MethodPost).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.create))

	r.Path("/current").Methods(http.MethodGet).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.current))

	r.Path("/{id}").Methods(http.MethodPut).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.touch))

	r.Path("/{id}").Methods(http.MethodDelete).Handler(alice.New(
		httpx.ContextBufferPool512(),
		httpauth.AuthenticateWithToken(t.jwtsecret),
		httpx.Timeout2s(),
	).ThenFunc(t.delete))
}

func (t *HTTPWireguard) search(w http.ResponseWriter, r *http.Request) {
	const resplimit = 128
	var (
		err  error
		resp = WireguardSearchResponse{
			Next: &WireguardSearchRequest{
				Offset: 0,
				Limit:  resplimit,
			},
		}
	)

	if err = t.decoder.Decode(resp.Next, r.Form); err != nil {
		log.Println(errorsx.Wrap(err, "unable to decode request"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	resp.Next.Limit = numericx.Min(resp.Next.Limit, resplimit)

	err = fs.WalkDir(os.DirFS(t.dir.Path()), ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}

		if path == "." {
			return nil
		}

		if d.IsDir() {
			return nil
		}

		resp.Items = append(resp.Items, &Wireguard{
			Id: path,
		})
		return nil
	})
	if err != nil {
		log.Println(errorsx.Wrap(err, "unable to walk directory"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &resp); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPWireguard) create(w http.ResponseWriter, r *http.Request) {
	var (
		err    error
		f      multipart.File
		buf    [bytesx.MiB]byte
		copied = &iox.Copied{Result: new(uint64)}
		mhash  = md5.New()
	)

	if f, _, err = r.FormFile("content"); err != nil {
		log.Println(errorsx.Wrap(err, "content parameter required"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	defer f.Close()

	tmp, err := fsx.CreateTemp(t.dir, "retrovibed.upload.*")
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

	raw, err := iox.String(tmp)
	if err != nil {
		log.Println(errorsx.Wrap(err, "failed to read configuration"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if _, err = wireguardx.FromWgQuick(string(raw), "retrovibed"); err != nil {
		log.Println(errorsx.Wrap(err, "failed to parse config"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err = os.Rename(tmp.Name(), t.dir.Path(md5x.FormatHex(mhash))); err != nil {
		log.Println(errorsx.Wrap(err, "failed to rename upload"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusInternalServerError))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &WireguardUploadResponse{
		Wireguard: &Wireguard{
			Id: md5x.FormatHex(mhash),
		},
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPWireguard) current(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		cfg *wireguardx.Config
	)

	encoded, err := os.ReadFile(t.dir.Path("_current"))
	if err != nil {
		log.Println(errorsx.Wrap(err, "failed to read configuration"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if cfg, err = wireguardx.FromWgQuick(string(encoded), "retrovibed"); err != nil {
		log.Println(errorsx.Wrap(err, "failed to parse config"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	_ = cfg

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &WireguardCurrentResponse{
		Wireguard: &Wireguard{Id: "_current"},
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPWireguard) touch(w http.ResponseWriter, r *http.Request) {
	// switches the current config
	var (
		err error
		id  = mux.Vars(r)["id"]
	)

	if err = os.Remove(t.dir.Path("_current")); fsx.IgnoreIsNotExist(err) != nil {
		log.Println(errorsx.Wrap(err, "failed to remove old config"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err = os.Symlink(t.dir.Path(id), t.dir.Path("_current")); err != nil {
		log.Println(errorsx.Wrap(err, "failed to symlink"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &WireguardTouchResponse{}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}

func (t *HTTPWireguard) delete(w http.ResponseWriter, r *http.Request) {
	var (
		err error
		cfg *wireguardx.Config
		id  = mux.Vars(r)["id"]
	)
	encoded, err := os.ReadFile(t.dir.Path(id))
	if err != nil {
		log.Println(errorsx.Wrap(err, "failed to read configuration"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if cfg, err = wireguardx.FromWgQuick(string(encoded), "retrovibed"); err != nil {
		log.Println(errorsx.Wrap(err, "failed to parse config"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}
	_ = cfg

	if err = os.Remove(t.dir.Path(id)); fsx.IgnoreIsNotExist(err) != nil {
		log.Println(errorsx.Wrap(err, "failed to remove config"))
		errorsx.Log(httpx.WriteEmptyJSON(w, http.StatusBadRequest))
		return
	}

	if err = httpx.WriteJSON(w, httpx.GetBuffer(r), &WireguardDeleteResponse{
		Wireguard: &Wireguard{Id: id},
	}); err != nil {
		log.Println(errorsx.Wrap(err, "unable to write response"))
		return
	}
}
