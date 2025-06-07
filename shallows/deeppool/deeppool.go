package deeppool

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"

	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
)

func Deeppool() string {
	return "localhost:8081"
}

func NewArchiver(c *http.Client) Archiver {
	return Archiver{
		c:        c,
		endpoint: Deeppool(),
	}
}

type Archiver struct {
	c        *http.Client
	endpoint string
}

func (t Archiver) Upload(ctx context.Context, mimetype string, r io.Reader) (m *Media, _ error) {
	var (
		mur MediaUploadResponse
	)
	contenttype, data, err := httpx.Multipart(func(w *multipart.Writer) error {
		part, lerr := w.CreatePart(httpx.NewMultipartHeader(mimetype, "content", "bin"))
		if lerr != nil {
			return errorsx.Wrap(lerr, "unable to create archive part")
		}

		if _, lerr = io.Copy(part, r); lerr != nil {
			return errorsx.Wrap(lerr, "unable to copy archive")
		}

		return nil
	})
	if err != nil {
		return nil, err
	}
	defer data.Close()

	resp, err := httpx.AsError(t.c.Post(fmt.Sprintf("https://%s/m/", t.endpoint), contenttype, data))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if err = json.NewDecoder(resp.Body).Decode(&mur); err != nil {
		return nil, err
	}

	return mur.Media, nil
}

func NewRetrieval(c *http.Client) Retrieval {
	return Retrieval{
		c:        c,
		endpoint: Deeppool(),
	}
}

type Retrieval struct {
	c        *http.Client
	endpoint string
}

func (t Retrieval) Download(ctx context.Context, id string, into io.Writer) error {
	resp, err := httpx.AsError(t.c.Get(fmt.Sprintf("https://%s/m/%s/download", t.endpoint, id)))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if _, err := io.Copy(into, resp.Body); err != nil {
		return err
	}

	return nil
}

type Ranger struct {
	c *http.Client
}

func (t Ranger) Download(ctx context.Context, id string, start, end uint64, into io.Writer) error {
	return nil
}
