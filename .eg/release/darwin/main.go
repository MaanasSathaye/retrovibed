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
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

// Baremetal command for darwin due to macosx nonsense for no cloud vms.
func main() {
	log.SetFlags(log.Flags() | log.Lshortfile)
	ctx, done := context.WithTimeout(context.Background(), egenv.TTL())
	defer done()

	runtime := shell.Runtime().
		User(egenv.User().Username).Group("staff").
		Environ("GOCACHE", egenv.CacheDirectory(".eg.cache", ".eg", "golang", "build")).
		Environ("GOMODCACHE", egenv.CacheDirectory(".eg.cache", ".eg", "golang", "mod")).
		Environ("PUB_CACHE", egenv.CacheDirectory(".eg.cache", ".eg", "dart"))

	dstdir := filepath.Join(egtarball.Path(tarballs.Retrovibed()), "retrovibed.app", "Contents", "MacOS")
	flutter := runtime.Directory(egenv.WorkingDirectory("console"))
	shallows := runtime.Directory(egenv.WorkingDirectory("shallows"))

	err := eg.Perform(
		ctx,
		eg.Build(eg.DefaultModule()),
		eg.Parallel(
			shell.Op(
				flutter.New("rm -rf build/macos/{x64,arm64}/debug").Lenient(true),
				flutter.New("flutter build macos --release lib/main.dart").Timeout(10*time.Minute),
				flutter.Newf("go -C retrovibedbind build -buildmode=c-shared --tags localdev -o %s/retrovibed.dylib ./...", egtarball.Path(tarballs.Retrovibed())),
			),
			shell.Op(
				shallows.Newf("go install ./cmd/...").Environ("GOBIN", dstdir),
			),
		),
		shell.Op(
			flutter.Newf("rsync -av build/macos/Build/Products/Release/retrovibed.app %s", egtarball.Path(tarballs.Retrovibed())),
			runtime.Newf("mv %s/{retrovibed.dylib,retrovibed.app/Contents/Frameworks}", egtarball.Path(tarballs.Retrovibed())),
			runtime.Newf("mv %s/{retrovibed.h,retrovibed.app/Contents/Frameworks}", egtarball.Path(tarballs.Retrovibed())),
			runtime.Newf("tree -L 3 %s", egtarball.Path(tarballs.Retrovibed())),
			runtime.Newf("ln -sf /Applications %s", filepath.Join(egtarball.Path(tarballs.Retrovibed()), "Applications")),
			// runtime.Newf("create-dmg '%s' '%s'", egenv.CacheDirectory("retrovibed.arm64.dmg"), filepath.Join(egtarball.Path(tarballs.Retrovibed()), "retrovibed.app")),
			runtime.Newf("tar -czvf %s -C %s .", egenv.CacheDirectory("retrovibed.darwin.arm64.tar.gz"), egtarball.Path(tarballs.Retrovibed())),
			// runtime.Newf("mkisofs -V retrovibed.app -D -R -apple -no-pad -o retrovibed.arm64.dmg %s", filepath.Join(egtarball.Path(tarballs.Retrovibed()), "retrovibed.app")),
		),
		eg.Module(
			ctx,
			eg.DefaultModule(),
			eg.Sequential(
				egbug.FileTree,
				shell.Op(shell.New("env | sort")),
				release.Tarball,
				release.DarwinDmg,
			),
		),
	)

	if err != nil {
		log.Fatalln(err)
	}
}
