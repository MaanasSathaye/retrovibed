package main

import (
	"context"
	"eg/compute/console"
	"eg/compute/maintainer"
	"eg/compute/release"
	"eg/compute/shallows"
	"log"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/eggit"
)

func main() {
	ctx, done := context.WithTimeout(context.Background(), egenv.TTL())
	defer done()

	deb := eg.Container(maintainer.Container)
	err := eg.Perform(
		ctx,
		eggit.AutoClone,
		eg.Build(deb.BuildFromFile(".eg/Containerfile")),
		eg.Module(
			ctx, deb,
			eg.Sequential(
				eg.Parallel(
					shallows.Generate,
					console.Generate,
				),
				eg.Parallel(
					eg.Sequential(console.GenerateBinding, console.BuildLinux),
					shallows.Compile(),
				),
				eg.Parallel(
					console.Tests,
					console.Linting,
					shallows.Test(),
				),
				eg.Parallel(
					console.Install,
					shallows.Install,
					// shell.Op(
					// 	shell.Newf("cp --verbose -R .dist/linux/* %s", egtarball.Path(tarballs.Retrovibed())),
					// 	shell.Newf("tree -L 3 %s", egtarball.Path(tarballs.Retrovibed())),
					// ),
				),
				release.Tarball,
				eg.Parallel(
					shallows.FlatpakManifest,
					console.FlatpakManifest,
				),
			),
		),
		release.Release,
		// eg.Module(
		// 	ctx, deb.OptionLiteral("--privileged"),
		// 	eg.Parallel(
		// 		console.FlatpakBuild,
		// 	),
		// ),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
