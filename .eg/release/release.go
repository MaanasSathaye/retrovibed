package release

import (
	"context"
	"eg/compute/tarballs"
	"log"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egbug"
	"github.com/egdaemon/eg/runtime/x/wasi/egdmg"
	"github.com/egdaemon/eg/runtime/x/wasi/eggithub"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

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
			shell.Op(podman.New("podman run --privileged --rm --volume .eg.cache/flatpak.client.yml:/retrovibed.client.yml:ro retrovibed.flatpak.distro.check.ubuntu.noble cat /retrovibed.client.yml").Privileged()),
			shell.Op(podman.New("podman run --privileged --rm --volume .eg.cache/flatpak.client.yml:/retrovibed.client.yml:ro retrovibed.flatpak.distro.check.ubuntu.noble").Privileged()),
		),
	)(ctx, op)
}

func Tarball(ctx context.Context, op eg.Op) error {
	archive := tarballs.Retrovibed()
	return eg.Sequential(
		egbug.Log("foo 0"),
		egtarball.Pack(archive),
		egbug.Log("foo 1"),
		egtarball.SHA256Op(archive),
		egbug.Log("foo 2"),
		shell.Op(
			shell.Newf("mv %s %s", egtarball.Archive(archive), egenv.CacheDirectory("retrovibed.darwin.arm64.tar.gz")),
		),
		egbug.Log("foo 3"),
	)(ctx, op)
}

func DarwinDmg(ctx context.Context, op eg.Op) error {
	log.Println("---------------------------------------------------------------------------------")
	b := egdmg.New(tarballs.Retrovibed(), egdmg.OptionBuildDir(egenv.CacheDirectory(".dist")))
	return eg.Sequential(
		egbug.Log("derp 0"),
		egdmg.Build(b, egtarball.Path(tarballs.Retrovibed())),
		egbug.Log("derp 1"),
		shell.Op(
			shell.Newf("mv %s %s", egdmg.Path(tarballs.Retrovibed()), egenv.CacheDirectory("retrovibed.darwin.arm64.dmg")),
		),
		egbug.Log("derp 2"),
	)(ctx, op)
}
