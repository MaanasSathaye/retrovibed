package cmdmedia

import (
	"compress/gzip"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/asynccompute"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/library"
)

type knownarchive struct {
	Directory string `flag:"" name:"directory" help:"work directory for the command"`
	Pattern   string `flag:"" name:"pattern" help:"name of the archive directory to create" default:"retrovibed.known.media.archive.*.d"`
}

func (t knownarchive) Run(gctx *cmdopts.Global) (err error) {
	var (
		dir  string
		v    library.Known
		derr error
	)

	d := jsonl.NewDecoder(os.Stdin)

	if strings.Contains(t.Pattern, "*") {
		dir, err = os.MkdirTemp(t.Directory, t.Pattern)
	} else {
		dir = filepath.Join(stringsx.FirstNonBlank(t.Directory, "."), t.Pattern)
		err = os.MkdirAll(dir, 0700)
	}
	if err != nil {
		return errorsx.Wrap(err, "unable to create archive directory")
	}

	for derr = d.Decode(&v); derr == nil; derr = d.Decode(&v) {
		v.AutoDescription = stringsx.Join("\n", v.Title, v.OriginalTitle, v.Overview)
		encoded, err := json.Marshal(v)
		if err != nil {
			return errorsx.Wrapf(err, "unable to encode record %s", v.UID)
		}

		path := filepath.Join(dir, fmt.Sprintf("%x%x", backoffx.DynamicHashWindow(v.Released.String(), 16), backoffx.DynamicHashWindow(v.UID, 48)))
		if err := fsx.AppendTo(path, []byte(fmt.Sprintf("%s\n", encoded)), 0600); err != nil {
			return errorsx.Wrapf(err, "unable to append record %s %s", v.UID, path)
		}
	}

	if errorsx.Ignore(derr, io.EOF) != nil {
		return derr
	}

	compressors := asynccompute.New(func(ctx context.Context, path string) error {
		in, err := os.Open(path)
		if err != nil {
			return err
		}
		defer in.Close()

		out, err := os.Create(fmt.Sprintf("%s.gz", path))
		if err != nil {
			return err
		}
		defer out.Close()
		gzout := gzip.NewWriter(out)

		if _, err := io.Copy(gzout, in); err != nil {
			return err
		}
		return errorsx.Compact(gzout.Flush(), gzout.Close(), os.RemoveAll(path))
	}, asynccompute.Workers[string](uint16(runtime.NumCPU())))

	w := fsx.Walk(os.DirFS(dir))

	for path := range w.Walk() {
		if path == "." {
			continue
		}

		if err := compressors.Run(gctx.Context, filepath.Join(dir, path)); err != nil {
			return err
		}
	}

	return errorsx.Compact(w.Err(), asynccompute.Shutdown(gctx.Context, compressors))
}
