package cmdtorrent

import (
	"fmt"
	"io/fs"
	"log"
	"os"

	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/fsx"
)

type remap struct {
	DryRun bool `flag:"" name:"dry-run" help:"print remapping without preforming" default:"false"`
}

func (t remap) Run(gctx *cmdopts.Global) (err error) {
	tvfs := fsx.DirVirtual(env.TorrentDir())

	log.Println("attempting to remap", tvfs.Path())
	return fs.WalkDir(os.DirFS(tvfs.Path()), ".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return nil
		}

		if path == "." {
			return nil
		}

		if d.IsDir() {
			return nil
		}

		// we only care about symlinks
		if d.Type()&fs.ModeSymlink == 0 {
			// log.Println("ignoring non-symlink", path)
			return nil
		}

		path = tvfs.Path(path)

		actual, err := os.Readlink(path)
		if err != nil {
			log.Println("failed to read link", path, err)
			return nil
		}

		npath := fmt.Sprintf("%s.oldlink", path)
		if t.DryRun {
			log.Println("renaming", path, "->", npath)
		} else if err = os.Rename(path, npath); err != nil {
			return err
		}

		// replace the symlink with the actual contents.
		if t.DryRun {
			log.Println("renaming", actual, "->", path)
		} else if err = os.Rename(actual, path); err != nil {
			return err
		}

		if t.DryRun {
			log.Println("symlinking", path, "->", actual)
		} else if err = os.Symlink(path, actual); err != nil {
			return err
		}

		return nil
	})
}
