package console

import (
	"context"
	"eg/compute/flatpakmods"
	"eg/compute/tarballs"
	"os"
	"path/filepath"
	"time"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egflatpak"
	"github.com/egdaemon/eg/runtime/x/wasi/egfs"
	"github.com/egdaemon/eg/runtime/x/wasi/eggithub"
	"github.com/egdaemon/eg/runtime/x/wasi/eggolang"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

func flutterRuntime() shell.Command {
	return shell.Runtime().Directory(egenv.WorkingDirectory("console")).EnvironFrom(eggolang.Env()...).Environ("PUB_CACHE", egenv.CacheDirectory(".eg", "dart"))
}

func Build(ctx context.Context, _ eg.Op) error {
	runtime := flutterRuntime()
	return shell.Run(
		ctx,
		runtime.New("rm -rf build/linux/x64/debug").Lenient(true),
		runtime.New("flutter build linux --release lib/main.dart"),
	)
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
		runtime.New("flutter create --platforms=linux ."),
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

func flatpak(final egflatpak.Module) *egflatpak.Builder {
	return egflatpak.New(
		"space.retrovibe.Console", "console",
		egflatpak.Option().SDK("org.gnome.Sdk", "47").Runtime("org.gnome.Platform", "47").
			Modules(
				flatpakmods.Libduckdb(),
				flatpakmods.Libass(),
				flatpakmods.Libbs2b(),
				flatpakmods.Libplacebo(),
				flatpakmods.Libx264(),
				flatpakmods.Libx265(),
				flatpakmods.Libffmpeg(),
				flatpakmods.Libmpv(),
				final,
			).
			AllowWayland().
			AllowDRI().
			AllowNetwork().
			AllowDownload().
			AllowMusic().
			AllowVideos().Allow(
			// we specify environment variables here so they show up in flatseal for easy adjustments.
			"--filesystem=host:ro",                          // for mpv
			"--socket=pulseaudio",                           // for mpv
			"--filesystem=xdg-run/pipewire-0:ro",            // for mpv
			"--filesystem=~/.duckdb:create",                 // for duckdb
			"--talk-name=org.freedesktop.portal.*",          // enable standard desktop functionality.
			"--share=ipc",                                   // enable standard desktop functionality.
			"--filesystem=xdg-run/gvfsd",                    // enable standard desktop functionality. (probably unnnecessary)
			"--env=LC_NUMERIC=C",                            // for mpv
			"--env=TMPDIR=/var/tmp/",                        // enaure golang sets its os.TempDir() to a working value.
			"--env=RETROVIBED_MDNS_DISABLED=true",           // disable MDNS when running in flatpak since it doesn't work.
			"--env=RETROVIBED_AUTO_IDENTIFY_MEDIA=false",    // automatically identify metadata for content. experimental.
			"--env=RETROVIBED_MEDIA_AUTO_ARCHIVE=true",      // enable content marked for archiving being uploaded into storage.
			"--env=RETROVIBED_MEDIA_AUTO_RECLAIM=false",     // allow automatically reclaiming disk space by removing archived data.
			"--env=RETROVIBED_TORRENT_AUTO_DISCOVERY=false", // peer scanning is an experimental feature.
			"--env=RETROVIBED_TORRENT_AUTO_BOOTSTRAP=true",  // auto bootstrap the dht from a global endpoint.
			"--env=RETROVIBED_TORRENT_PORT=",                // manually set the public torrent port.
			"--env=RETROVIBED_TORRENT_ALLOW_SEEDING=true",   // allow uploading to peers
			"--env=RETROVIBED_TORRENT_PUBLIC_IP4=\"\"",      // manually set the public ipv4 address.
			"--env=RETROVIBED_TORRENT_PUBLIC_IP6=\"\"",      // manually set the public ipv6 address.
			"--env=RETROVIBED_JWT_SECRET=",                  // specify the jwt secret to use for signing tokens. generally this should not be necessary.
			"--env=RETROVIBED_SELF_SIGNED_HOSTS=127.0.0.1",  // TLS hosts to include in the self signed certificate.
		)...)
}

// build ensures that the flatpak has all the necessary componentry for the generated manifest.
func FlatpakBuild(ctx context.Context, op eg.Op) error {
	return egflatpak.Build(ctx, shell.Runtime().Timeout(30*time.Minute), flatpak(
		egflatpak.ModuleTarball(
			eggithub.DownloadURL(tarballs.Retrovibed()),
			egtarball.SHA256(tarballs.Retrovibed()),
		),
	))
}

// Manifest generates the manifest for distribution.
func FlatpakManifest(ctx context.Context, o eg.Op) error {
	return egflatpak.ManifestOp(egenv.CacheDirectory("flatpak.client.yml"), flatpak(
		moduleTarball(eggithub.DownloadURL(tarballs.Retrovibed()), egtarball.SHA256(tarballs.Retrovibed())),
	))(ctx, o)
}

func moduleTarball(url, sha256d string) egflatpak.Module {
	return egflatpak.NewModule("tarball", "simple", egflatpak.ModuleOptions().Commands(
		"ls -lha .",
		"mv usr/share/applications/retrovibed.desktop /app/share/applications/space.retrovibe.Console.desktop",
		"mv usr/share/icons/hicolor/scalable/apps/retrovibed.svg /app/share/icons/hicolor/scalable/apps/space.retrovibe.Console.svg",
		"rm -rf usr",
		"rm -rf etc",
		"ls -lha .",
		"cp -r . /app/bin",
		"cp /app/bin/lib/retrovibed.so /app/lib",
	).Sources(egflatpak.SourceTarball(url, sha256d))...)
}
