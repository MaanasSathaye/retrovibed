package release

import (
	"context"
	"eg/compute/tarballs"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/eggithub"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

func Tarball(ctx context.Context, op eg.Op) error {
	archive := tarballs.Retrovibed()
	return eg.Perform(
		ctx,
		egtarball.Pack(archive),
		egtarball.SHA256Op(archive),
	)
}

func Release(ctx context.Context, op eg.Op) error {
	return eg.Perform(
		ctx,
		eggithub.Release(
			egtarball.Archive(tarballs.Retrovibed()),
			egenv.CacheDirectory("flatpak.client.yml"),
			// egenv.CacheDirectory("flatpak.daemon.yml"),
		),
	)
}

func DistroBuilds(ctx context.Context, op eg.Op) error {
	podman := shell.Runtime().Environ("XFG_DATA_HOME", egenv.CacheDirectory())
	return eg.Sequential(
		eg.Parallel(
			shell.Op(
				podman.New("echo ---------------------------------------------------------------"),
				podman.New("podman build -t retrovibed.flatpak.distro.check.ubuntu.noble -f .dist/distrobuilds/ubuntu.noble").Privileged(),
				podman.New("echo ---------------------------------------------------------------"),
			),
			// shell.Op(shell.New("podman build -tag retrovibed.flatpak.distro.check.ubuntu.oracular -f .dist/distrobuilds/ubuntu.oracular")),
		),
		eg.Parallel(
			shell.Op(podman.New("tree -a -L 1")),
			shell.Op(podman.New("podman run --privileged --rm --volume .eg.cache/flatpak.client.yml:/retrovibed.client.yml:ro retrovibed.flatpak.distro.check.ubuntu.noble cat /retrovibed.client.yml").Privileged()),
			shell.Op(podman.New("podman run --privileged --rm --volume .eg.cache/flatpak.client.yml:/retrovibed.client.yml:ro retrovibed.flatpak.distro.check.ubuntu.noble").Privileged()),
		),
	)(ctx, op)
}
