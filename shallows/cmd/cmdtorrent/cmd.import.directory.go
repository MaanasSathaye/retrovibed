package cmdtorrent

import (
	"context"
	"encoding/json"
	"fmt"
	"io/fs"
	"net/http"
	"os"
	"path/filepath"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/asynccompute"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/media"
)

type importDirectory struct {
	Endpoint  string `flag:"" name:"peer" help:"http address for the daemon you want to import to, usually you do this on device" default:"localhost:9998"`
	Entropy   string `flag:"" name:"entropy" help:"encryption entropy value to set for uploads" default:""`
	Mimetype  string `flag:"" name:"mimetype" help:"mimetype of the media if known and consistent"`
	Directory string `arg:"" name:"directory" help:"directory containing the content to import. each immediate file / directory generates a torrent torrent. subdirectories create multi file torrents"`
}

func (t importDirectory) Run(gctx *cmdopts.Global) error {
	type Workload struct {
		Path  string
		Entry fs.DirEntry
	}

	encoder := jsonl.NewEncoder(os.Stdout)
	c := authn.AutoLocalOauth2Client(gctx.Context)

	publisher := asynccompute.New(func(ctx context.Context, w Workload) (err error) {
		var (
			m = new(media.PublishedUploadResponse)
		)
		defer func() {
			errorsx.Log(errorsx.Wrapf(err, "import failed: %s", w.Path))
		}()

		info, err := metainfo.NewFromPath(w.Path)
		if err != nil {
			return err
		}

		md, err := torrent.NewFromInfo(info, torrent.OptionStorage(storage.NewFile(filepath.Dir(w.Path), storage.FileOptionPathMakerFixed(filepath.Base(w.Path)))), torrent.OptionDisplayName(info.Name))
		if err != nil {
			return err
		}

		mimetype, data, err := media.PublishRequest(ctx, md, &media.PublishedUploadRequest{Entropy: t.Entropy, Mimetype: t.Mimetype})
		if err != nil {
			return err
		}
		defer data.Close()

		req, err := http.NewRequestWithContext(gctx.Context, http.MethodPost, fmt.Sprintf("https://%s/d/publish", t.Endpoint), data)
		if err != nil {
			return err
		}
		req.Header.Add("Content-Type", mimetype)

		resp, err := httpx.AsError(c.Do(req))
		if err != nil {
			return err
		}
		defer resp.Body.Close()

		if err := json.NewDecoder(resp.Body).Decode(m); err != nil {
			return err
		}

		return encoder.Encode(m.Published)
	})

	w := fsx.Walk(os.DirFS(t.Directory))
	for p, e := range w.Walk() {
		if p == "." {
			continue
		}

		if err := publisher.Run(gctx.Context, Workload{Path: filepath.Join(t.Directory, p), Entry: e}); err != nil {
			return errorsx.Wrap(err, "unable to enqueue publish workload")
		}
	}

	if err := w.Err(); err != nil {
		return errorsx.Wrapf(err, "failed to import directory: %s", t.Directory)
	}

	if err := asynccompute.Shutdown(gctx.Context, publisher); err != nil {
		return err
	}

	return nil
}
