package cmdglobalmain

import (
	"context"
	"database/sql"
	"log"
	"net"
	"os"
	"reflect"
	"runtime"
	"strconv"
	"sync"
	"syscall"
	"time"

	"github.com/alecthomas/kong"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/cmd/cmdmedia"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/cmd/cmdtorrent"
	"github.com/retrovibed/retrovibed/cmd/retrovibed/daemons"
	"github.com/retrovibed/retrovibed/internal/debugx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/sshx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/meta/identityssh"
	"github.com/willabides/kongplete"
	"golang.org/x/crypto/ssh"

	_ "github.com/benbjohnson/immutable"
)

func Hostname() string {
	return stringsx.FirstNonBlank(errorsx.Zero(os.Hostname()), "localhost")
}

func Profile(db *sql.DB) (err error) {
	var (
		id ssh.Signer
	)
	ctx, done := context.WithTimeout(context.Background(), time.Second)
	defer done()

	if id, err = sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath()); err != nil {
		return err
	}

	if err = identityssh.ImportPublicKey(ctx, db, id.PublicKey()); err != nil {
		return errorsx.Wrap(err, "unable to import ssh identity")
	}

	return nil
}

func Main(args ...string) {
	var shellCli struct {
		cmdopts.Global
		cmdopts.PeerID
		cmdopts.SSHID
		Version  cmdopts.Version     `cmd:"" help:"display versioning information"`
		Identity cmdmeta.Identity    `cmd:"" help:"identity management commands"`
		Media    cmdmedia.Commands   `cmd:"" help:"media management (import/export)"`
		Torrent  cmdtorrent.Commands `cmd:"" help:"torrent related sub commands"`
		Daemon   daemons.Command     `cmd:"" help:"run the backend daemon" default:"true"`
	}

	var (
		err error
		ctx *kong.Context
	)

	shellCli.Context, shellCli.Shutdown = context.WithCancel(context.Background())
	shellCli.Cleanup = &sync.WaitGroup{}

	log.SetFlags(log.Lshortfile | log.LUTC | log.Ltime)

	go debugx.DumpOnSignal(shellCli.Context, syscall.SIGUSR2)
	go cmdopts.Cleanup(shellCli.Context, shellCli.Shutdown, shellCli.Cleanup, os.Kill, os.Interrupt, syscall.SIGTERM)(func() {
		log.Println("waiting for systems to shutdown")
	})

	go debugx.OnSignal(shellCli.Context, func(ctx context.Context) error {
		dctx, done := context.WithTimeout(ctx, envx.Duration(time.Second, "DEEPPOOL_PROFILING_DURATION"))
		defer done()

		log.Println("PROFILING INITIATED")
		defer log.Println("PROFILING COMPLETED")

		switch envx.String("cpu", "DEEPPOOL_PROFILING_STRATEGY") {
		case "heap":
			return debugx.Heap(envx.String(os.TempDir(), "CACHE_DIRECTORY"))(dctx)
		case "mem":
			return debugx.Memory(envx.String(os.TempDir(), "CACHE_DIRECTORY"))(dctx)
		default:
			return debugx.CPU(envx.String(os.TempDir(), "CACHE_DIRECTORY"))(dctx)
		}
	}, syscall.SIGUSR1)

	parser := kong.Must(
		&shellCli,
		kong.Name(userx.DefaultRelRoot()),
		kong.Description("daemon"),
		kong.Vars{
			"vars_timestamp_started":  time.Now().UTC().Format(time.RFC3339),
			"vars_random_seed":        uuid.Must(uuid.NewV4()).String(),
			"vars_cores":              strconv.Itoa(runtime.NumCPU()),
			"env_mdns_disabled":       env.MDNSDisabled,
			"env_auto_bootstrap":      env.AutoBootstrap,
			"env_auto_discovery":      env.AutoDiscovery,
			"env_self_signed_hosts":   env.SelfSignedHosts,
			"env_daemon_socket":       env.DaemonSocket,
			"env_torrent_port":        env.TorrentPort,
			"env_torrent_ipv4":        env.TorrentPublicIP4,
			"env_torrent_ipv6":        env.TorrentPublicIP6,
			"env_auto_identify_media": env.AutoIdentifyMedia,
		},
		kong.UsageOnError(),
		kong.Bind(
			&shellCli.Global,
		),
		kong.Bind(
			&shellCli.PeerID,
		),
		kong.Bind(
			&shellCli.SSHID,
		),
		kong.TypeMapper(reflect.TypeOf(&net.IP{}), kong.MapperFunc(cmdopts.ParseIP)),
		kong.TypeMapper(reflect.TypeOf(&net.TCPAddr{}), kong.MapperFunc(cmdopts.ParseTCPAddr)),
		kong.TypeMapper(reflect.TypeOf([]*net.TCPAddr(nil)), kong.MapperFunc(cmdopts.ParseTCPAddrArray)),
	)

	// Run kongplete.Complete to handle completion requests
	kongplete.Complete(parser)

	if ctx, err = parser.Parse(args); err != nil {
		log.Fatalln(err)
	}

	if err = errorsx.LogErr(ctx.Run()); err != nil {
		shellCli.Shutdown()
	}

	shellCli.Cleanup.Wait()
	log.Println("system cleanup completed")
	ctx.FatalIfErrorf(err)
}
