package egdmg

import (
	"context"
	"embed"
	"io/fs"
	"path/filepath"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/x/wasi/egfs"
	"github.com/retrovibed/retrovibed/internal/langx"
)

//go:embed .skel
var skel embed.FS

type Option func(*Bundle)

func OptionIconPath(s string) Option {
	return func(d *Bundle) {
		d.icon = s
	}
}

func New(name string, options ...Option) Bundle {
	return langx.Clone(Bundle{
		name: name,
	}, options...)
}

type Bundle struct {
	icon string
	name string
}

func Build(c eg.ContainerRunner, archive fs.FS) eg.OpFn {
	return func(ctx context.Context, o eg.Op) error {
		if err := egfs.CloneFS(ctx, egenv.EphemeralDirectory(), ".", archive); err != nil {
			return err
		}

		return eg.Build(c.BuildFromFile(filepath.Join(egenv.EphemeralDirectory(), relpath)))(ctx, o)
	}
}
