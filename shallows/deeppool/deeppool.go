package deeppool

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"os"

	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
)

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
	defer os.Remove(data.Name())
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

func NewRanger(c *http.Client) Ranger {
	return Ranger{
		c:        c,
		endpoint: Deeppool(),
	}
}

type Ranger struct {
	c        *http.Client
	endpoint string
}

func (t Ranger) Download(ctx context.Context, id string, start, end uint64, into io.Writer) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, fmt.Sprintf("https://%s/m/%s/download", t.endpoint, id), nil)
	if err != nil {
		return err
	}
	httpx.RangeHeaders(req, start, end)

	resp, err := httpx.AsError(t.c.Do(req))
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if _, err := io.Copy(into, resp.Body); err != nil {
		return err
	}

	return nil
}
