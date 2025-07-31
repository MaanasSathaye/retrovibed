package main

import (
	"context"
	"eg/compute/console"
	"eg/compute/shallows"
	"log"
	"os"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/eggit"
	"github.com/egdaemon/eg/runtime/x/wasi/egfs"
)

// Baremetal command for darwin due to macosx nonsense for no cloud vms.
func main() {
	ctx, done := context.WithTimeout(context.Background(), egenv.TTL())
	defer done()

	log.Println(egfs.Inspect(ctx, os.DirFS("/eg.mnt/.eg.runtime")))
	log.Println(egfs.Inspect(ctx, os.DirFS("/workload")))
	// deb := eg.Container(maintainer.Container)
	err := eg.Perform(
		ctx,
		eggit.AutoClone,
		eg.Parallel(
			eg.Sequential(console.GenerateBinding, console.BuildDarwin),
			shallows.Compile(),
		),
		// egtarball.Clean(
		// 	eg.Parallel(
		// 		console.Install,
		// 		shallows.Install,
		// 	),
		// 	shell.Op(
		// 		shell.Newf("tree -L 3 %s", egtarball.Path(tarballs.Retrovibed())),
		// 	),
		// 	release.Tarball,
		// 	release.DarwinDmg,
		// ),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
