package main

import (
	"context"
	"eg/compute/console"
	"eg/compute/release"
	"eg/compute/tarballs"
	"log"
	"path/filepath"
	"time"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egbug"
	"github.com/egdaemon/eg/runtime/x/wasi/eggithub"
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
			console.GenerateFlutter,
			egbug.DebugFailure(
				shell.Op(
					flutter.New("rm -rf build/macos/{x64,arm64}/debug").Lenient(true),
					flutter.New("flutter build macos --release lib/main.dart").Timeout(10*time.Minute),
					flutter.Newf("go -C retrovibedbind build -buildmode=c-shared --tags localdev -o build/macos/Build/Products/Release/retrovibed.app/Contents/Frameworks/retrovibed.dylib ./..."),
				),
				shell.Op(shell.New("flutter failed to build app")),
			),
			shell.Op(
				shallows.Newf("go install ./cmd/...").Environ("GOBIN", dstdir),
			),
			shell.Op(
				flutter.New("tree build/macos/Build/Products/Release/retrovibed.app"),
				flutter.Newf("cp -R build/macos/Build/Products/Release/retrovibed.app %s", egenv.CacheDirectory()),
			),
			release.DarwinDmg,
			eg.Module(
				ctx,
				eg.DefaultModule(),
				eg.Sequential(
					eggithub.Release(
						egenv.CacheDirectory("retrovibed.darwin.arm64.dmg"),
					),
				),
			),
		),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
