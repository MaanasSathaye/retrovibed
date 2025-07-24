package cmdmedia

import (
	"context"
	"fmt"
	"io"
	"io/fs"
	"log"
	"os"
	"path/filepath"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/asynccompute"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/tracking"
)

type publish struct {
	Community string `flag:"" name:"community" help:"id of the community to publish to, by default uses the name of the directory"`
	Endpoint  string `flag:"" name:"peer" help:"http address for the daemon you want to upload to, usually you do this on device"  default:"localhost:9998"`
	Directory string `arg:"" name:"directory" help:"directory containing the content to publish immediate each immediate file / directory generates a torrent"`
}

func (t publish) Run(gctx *cmdopts.Global) error {
	type Workload struct {
		Path  string
		Entry fs.DirEntry
	}

	c := authn.AutoLocalOauth2Client(gctx.Context)

	publisher := asynccompute.New(func(ctx context.Context, w Workload) error {
		log.Println("DERP DERP", w.Path, w.Entry.Name(), w.Entry.IsDir())
		mimetype, data, err := tracking.PublishRequest(ctx, w.Path)
		if err != nil {
			return err
		}

		defer data.Close()

		resp, err := httpx.AsError(c.Post(fmt.Sprintf("https://%s/d/publish", t.Endpoint), mimetype, data))
		if err != nil {
			return err
		}
		defer resp.Body.Close()

		encoded, err := io.ReadAll(resp.Body)
		if err != nil {
			return err
		}

		log.Println("DERP DERP", string(encoded))

		// if err = json.NewDecoder(resp.Body).Decode(&mur); err != nil {
		// 	return err
		// }
		return nil
	})

	w := fsx.Walk(os.DirFS(t.Directory))
	for p, e := range w.Walk() {
		if err := publisher.Run(gctx.Context, Workload{Path: filepath.Join(t.Directory, p), Entry: e}); err != nil {
			return errorsx.Wrap(err, "unable to enqueue publish workload")
		}
	}

	if err := w.Err(); err != nil {
		return err
	}

	log.Println("WAKA SHUTDOWN")
	return asynccompute.Shutdown(gctx.Context, publisher)
}
