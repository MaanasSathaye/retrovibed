package console

import (
	"context"
	"eg/compute/tarballs"
	"os"
	"path/filepath"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egfs"
	"github.com/egdaemon/eg/runtime/x/wasi/eggolang"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

func flutterRuntime() shell.Command {
	return shell.Runtime().
		Directory(egenv.WorkingDirectory("console")).
		EnvironFrom(eggolang.Env()...).
		Environ("PUB_CACHE", egenv.CacheDirectory(".eg", "dart"))
}

func Tests(ctx context.Context, _ eg.Op) error {
	runtime := flutterRuntime()
	return shell.Run(
		ctx,
		runtime.New("flutter test"),
	)
}

func Linting(ctx context.Context, _ eg.Op) error {
	runtime := flutterRuntime()
	return shell.Run(
		ctx,
		runtime.New("flutter analyze"),
	)
}

func GenerateBinding(ctx context.Context, _ eg.Op) error {
	runtime := flutterRuntime()
	return shell.Run(
		ctx,
		runtime.New("go -C retrovibedbind build -buildmode=c-shared --tags duckdb_use_lib,localdev -o ../build/nativelib/retrovibed.so ./..."),
		runtime.New("dart run ffigen --config ffigen.yaml"),
	)
}

func Generate(ctx context.Context, op eg.Op) error {
	return eg.Sequential(
		GenerateFlutter,
		GenerateProtocol,
	)(ctx, op)
}

func GenerateFlutter(ctx context.Context, _ eg.Op) error {
	runtime := flutterRuntime()
	return shell.Run(
		ctx,
		// runtime.New("flutter clean"),
		runtime.New("flutter create --org space.retrovibe --platforms=linux,macos ."),
		runtime.New("flutter pub get"),
	)
}

func GenerateProtocol(ctx context.Context, _ eg.Op) error {
	runtime := shell.Runtime()
	return shell.Run(
		ctx,
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/meta -I.proto .proto/meta.daemon.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/meta -I.proto .proto/meta.profile.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/meta -I.proto .proto/meta.authz.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/meta -I.proto .proto/meta.account.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/meta -I.proto .proto/meta.authn.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/billing -I.proto .proto/meta.billing.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/wireguard -I.proto .proto/meta.wireguard.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/media -I.proto .proto/media.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/media -I.proto .proto/media.known.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/media -I.proto .proto/content.addressable.storage.proto"),
		runtime.New("PATH=\"${PATH}:${HOME}/.pub-cache/bin\" protoc --dart_out=grpc:console/lib/rss -I.proto .proto/rss.proto"),
	)
}

func Install(ctx context.Context, op eg.Op) error {
	runtime := shell.Runtime()
	dstdir := egtarball.Path(tarballs.Retrovibed())
	builddir := egenv.WorkingDirectory("console", "build")
	bundledir := filepath.Join(builddir, egfs.FindFirst(os.DirFS(builddir), "bundle"))
	libdir := filepath.Join(builddir, "nativelib")
	return shell.Run(
		ctx,
		runtime.Newf("mkdir -p %s", dstdir),
		runtime.Newf("mv %s/retrovibed %s/console", bundledir, bundledir),
		runtime.Newf("ls -lha %s", bundledir),
		runtime.Newf("echo cp -R %s/* %s", bundledir, dstdir),
		runtime.Newf("cp -R %s/* %s", bundledir, dstdir),
		runtime.Newf("cp -R %s/* %s/lib", libdir, dstdir),
		// runtime.Newf("tree %s", dstdir),
	)
}
