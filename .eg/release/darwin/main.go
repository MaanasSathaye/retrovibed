package main

import (
	"context"
	"eg/compute/tarballs"
	"log"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

// Baremetal command for darwin due to macosx nonsense for no cloud vms.
func main() {
	log.SetFlags(log.Flags() | log.Lshortfile)
	ctx, done := context.WithTimeout(context.Background(), egenv.TTL())
	defer done()

	log.Println("DERP DERP", egenv.WorkingDirectory())
	log.Println("Tarball", egtarball.Path(tarballs.Retrovibed()))
	runtime := shell.Runtime().
		User(egenv.User().Username).Group("staff").
		Environ("GOCACHE", egenv.WorkingDirectory(".eg.cache", ".eg", "golang", "build")).
		Environ("GOMODCACHE", egenv.WorkingDirectory(".eg.cache", ".eg", "golang", "mod")).
		Environ("PUB_CACHE", egenv.WorkingDirectory(".eg.cache", ".eg", "dart"))

	dstdir := egtarball.Path(tarballs.Retrovibed())
	flutter := runtime.Directory(egenv.WorkingDirectory("console"))
	shallows := runtime.Directory(egenv.WorkingDirectory("shallows"))
	err := eg.Perform(
		ctx,
		// egtarball.Clean(
		eg.Parallel(
			shell.Op(
				flutter.New("go -C retrovibedbind build -buildmode=c-shared --tags localdev -o ../build/nativelib/retrovibed.so ./..."),
				flutter.New("rm -rf build/macos/{x64,arm64}/debug").Lenient(true),
				flutter.New("flutter build macos --release lib/main.dart"),
			),
			shell.Op(
				shallows.Newf("go install ./cmd/...").Environ("GOBIN", dstdir),
			),
		),
		// egtarball.Clean(
		// eg.Parallel(
		// 	console.Install,
		// 	shallows.Install,
		// ),
		shell.Op(
			flutter.Newf("rsync build/macos/Build/Products/Release/retrovibed.app/ %s", egtarball.Path(tarballs.Retrovibed())),
			shell.Newf("tree -L 3 %s", egtarball.Path(tarballs.Retrovibed())),
		),
		// 	release.Tarball,
		// 	release.DarwinDmg,
		// ),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
