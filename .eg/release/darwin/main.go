package main

import (
	"context"
	"eg/compute/release"
	"eg/compute/tarballs"
	"log"
	"path/filepath"
	"time"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egbug"
	"github.com/egdaemon/eg/runtime/x/wasi/eggolang"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

// Baremetal command for darwin due to macosx nonsense for no cloud vms.
func main() {
	log.SetFlags(log.Flags() | log.Lshortfile)
	ctx, done := context.WithTimeout(context.Background(), egenv.TTL())
	defer done()

	runtime := shell.Runtime().
		EnvironFrom(eggolang.Env()...).
		Environ("PUB_CACHE", egenv.CacheDirectory(".eg", "dart"))

	dstdir := filepath.Join(egtarball.Path(tarballs.Retrovibed()), "retrovibed.app", "Contents", "MacOS")
	flutter := runtime.Directory(egenv.WorkingDirectory("console"))
	shallows := runtime.Directory(egenv.WorkingDirectory("shallows"))

	err := eg.Perform(
		ctx,
		eg.Build(eg.DefaultModule()),
		eg.Sequential(
			egbug.DebugFailure(
				shell.Op(
					flutter.New("rm -rf build/macos/{x64,arm64}/debug").Lenient(true),
					flutter.New("flutter build macos --release lib/main.dart").Timeout(10*time.Minute),
					flutter.Newf("go -C retrovibedbind build -buildmode=c-shared --tags localdev -o %s/retrovibed.dylib ./...", egtarball.Path(tarballs.Retrovibed())),
				),
				shell.Op(shell.New("DERP DERP!!!!!!!!!!!!!!!!!!!!!!!!")),
			),
			shell.Op(
				shallows.Newf("go install ./cmd/...").Environ("GOBIN", dstdir),
			),
		),
		shell.Op(
			runtime.New("echo zorp 0"),
			flutter.Newf("rsync -av build/macos/Build/Products/Release/retrovibed.app %s", egtarball.Path(tarballs.Retrovibed())),
			runtime.New("echo zorp 1"),
			runtime.Newf("mv %s/{retrovibed.dylib,retrovibed.app/Contents/Frameworks}", egtarball.Path(tarballs.Retrovibed())),
			runtime.New("echo zorp 2"),
			runtime.Newf("mv %s/{retrovibed.h,retrovibed.app/Contents/Frameworks}", egtarball.Path(tarballs.Retrovibed())),
			runtime.New("echo zorp 3"),
		),
		eg.Module(
			ctx,
			eg.DefaultModule(),
			eg.Sequential(
				release.Tarball,
				release.DarwinDmg,
			),
		),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
