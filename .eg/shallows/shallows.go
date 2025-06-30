package shallows

import (
	"context"
	"eg/compute/flatpakmods"
	"eg/compute/tarballs"
	"strings"
	"time"

	"github.com/egdaemon/eg/runtime/wasi/eg"
	"github.com/egdaemon/eg/runtime/wasi/egenv"
	"github.com/egdaemon/eg/runtime/wasi/shell"
	"github.com/egdaemon/eg/runtime/x/wasi/egflatpak"
	"github.com/egdaemon/eg/runtime/x/wasi/eggithub"
	"github.com/egdaemon/eg/runtime/x/wasi/eggolang"
	"github.com/egdaemon/eg/runtime/x/wasi/egtarball"
)

var buildTags = []string{"duckdb_use_lib"}

func rootdir() string {
	return egenv.WorkingDirectory("shallows")
}

func shellruntime() shell.Command {
	return eggolang.Runtime().Directory(rootdir()).Environ(
		"CACHE_DIRECTORY", egenv.CacheDirectory(),
	)
}

func Generate(ctx context.Context, op eg.Op) error {
	return eg.Sequential(
		GenerateProtocol,
		GenerateGogen,
	)(ctx, op)
}

func GenerateGogen(ctx context.Context, _ eg.Op) error {
	gruntime := shellruntime()
	return shell.Run(
		ctx,
		gruntime.New("go generate ./... && go fmt ./...").Timeout(30*time.Minute),
	)
}

func GenerateProtocol(ctx context.Context, op eg.Op) error {
	gruntime := shellruntime()
	return shell.Run(
		ctx,
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.account.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.account.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.profile.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.profile.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.authz.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.authz.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.daemon.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.daemon.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.wireguard.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.wireguard.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmeta.authn.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=Mmeta.account.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=Mmeta.profile.proto=github.com/retrovibed/retrovibed/metaapi --go_opt=paths=source_relative --go_out=metaapi meta.authn.proto"),
		// media
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmedia.proto=github.com/retrovibed/retrovibed/media --go_opt=paths=source_relative --go_out=media media.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mmedia.known.proto=github.com/retrovibed/retrovibed/media --go_opt=paths=source_relative --go_out=media media.known.proto"),
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mrss.proto=github.com/retrovibed/retrovibed/rss --go_opt=paths=source_relative --go_out=rss rss.proto"),
		// block cache
		gruntime.New("protoc --proto_path=../.proto --go_opt=Mcontent.addressable.storage.proto=github.com/retrovibed/retrovibed/deeppool --go_opt=paths=source_relative --go_out=deeppool content.addressable.storage.proto"),
	)
}

func Install(ctx context.Context, _ eg.Op) error {
	// go install -ldflags=\"-extldflags=-static\" -tags no_duckdb_arrow ./cmd/shallows/...
	dstdir := egtarball.Path(tarballs.Retrovibed())
	gruntime := shellruntime()
	return shell.Run(
		ctx,
		gruntime.Newf("go install -tags %s ./cmd/...", strings.Join(buildTags, ",")).Environ("GOBIN", dstdir),
	)
}

func Compile() eg.OpFn {
	return eggolang.AutoCompile(
		eggolang.CompileOption.BuildOptions(
			eggolang.Build(
				eggolang.BuildOption.Tags(buildTags...),
				eggolang.BuildOption.WorkingDirectory(rootdir()),
			),
		),
	)
}

func Test() eg.OpFn {
	return eg.Sequential(eggolang.AutoTest(
		eggolang.TestOption.BuildOptions(
			eggolang.Build(
				eggolang.BuildOption.Tags(buildTags...),
				eggolang.BuildOption.WorkingDirectory(rootdir()),
			),
		),
	),
		eggolang.RecordCoverage,
	)
}

func FlatpakManifest(ctx context.Context, o eg.Op) error {
	b := egflatpak.New(
		"space.retrovibe.Daemon", "retrovibed",
		egflatpak.Option().SDK("org.gnome.Sdk", "47").Runtime("org.gnome.Platform", "47").
			Modules(
				flatpakmods.Libduckdb(),
				egflatpak.NewModule("retrovibed", "simple", egflatpak.ModuleOptions().Commands(
					"cp -r . /app/bin",
				).Sources(
					egflatpak.SourceTarball(
						eggithub.DownloadURL(tarballs.Retrovibed()), egtarball.SHA256(tarballs.Retrovibed()),
						egflatpak.SourceOptions().Destination("retrovibed.tar.xz")...,
					),
				)...),
			).
			AllowWayland().
			AllowDRI().
			AllowNetwork().
			AllowDownload().
			AllowMusic().
			AllowVideos().Allow(
			"--filesystem=~/Downloads:ro",  // bug in flatpak doesn't properly grant access to xdg-download
			"--filesystem=~/Videos:create", // bug in flatpak doesn't properly grant full access to videos directory
			"--filesystem=~/Music:create",  // bug in flatpak doesn't properly grant full access to music directory
		)...)

	return egflatpak.ManifestOp(egenv.CacheDirectory("flatpak.daemon.yml"), b)(ctx, o)
}
