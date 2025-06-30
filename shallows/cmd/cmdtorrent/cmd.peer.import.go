package cmdtorrent

import (
	"bufio"
	"context"
	"database/sql"
	"fmt"
	"iter"
	"log"
	"net"
	"os"
	"strconv"
	"time"

	"github.com/davecgh/go-spew/spew"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/bep0051"
	"github.com/james-lawrence/torrent/connections"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/asynccompute"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/tracking"
	"golang.org/x/crypto/ssh"
)

type logging interface {
	Println(v ...interface{})
	Printf(format string, v ...interface{})
	Print(v ...interface{})
}

type importPeer struct {
	Peer           []string `flag:"" name:"peer" help:"peer(s) to connect to and download the provided torrents from" default:"localhost:10000"`
	Directory      string   `flag:"" name:"directory" help:"specify the directory to download torrents into" default:""`
	Archive        bool     `flag:"" name:"archive" help:"mark imported media for archival" default:"false"`
	Magnets        string   `arg:"" name:"magnets" help:"file containing magnet links to download, defaults to stdin" default:""`
	TorrentPrivate bool     `flag:"" name:"torrent-private" help:"restrict torrent connections to private networks" env:"${env_torrent_private}" default:"false"`
}

func (t importPeer) torrents(tstore fsx.Virtual) iter.Seq2[string, torrent.Metadata] {
	return func(yield func(string, torrent.Metadata) bool) {
		src := os.Stdin

		if stringsx.Present(t.Magnets) {
			var (
				err error
			)

			if src, err = os.Open(t.Magnets); err != nil {
				log.Fatalln("failed to open magnets source", err)
			}
		}

		s := bufio.NewScanner(src)
		for s.Scan() {
			magnet, err := torrent.NewFromMagnet(s.Text())
			if err != nil {
				log.Println("unable to parse magnet link", err)
				return
			}

			infopath := tstore.Path(fmt.Sprintf("%s.torrent", magnet.ID))
			if _, err := os.Stat(infopath); err == nil {
				magnet.InfoBytes, _ = os.ReadFile(infopath)
				log.Println("loaded existing torrent info", infopath)
			} else {
				log.Println("torrent info unavailable", infopath)
			}

			if !yield(s.Text(), magnet) {
				return
			}
		}

		if err := s.Err(); err != nil {
			log.Fatalln(err)
		}
	}
}

func (t importPeer) Run(gctx *cmdopts.Global, id *cmdopts.SSHID) (err error) {
	type workload struct {
		magnet string
		meta   torrent.Metadata
	}

	var (
		db        *sql.DB
		peerid    = krpc.IdFromString(md5x.String(ssh.FingerprintSHA256(id.PublicKey())))
		tnetwork  torrent.Binder
		bootstrap torrent.ClientConfigOption = torrent.ClientConfigNoop
		firewall  torrent.ClientConfigOption = torrent.ClientConfigNoop
	)

	gctx.Cleanup.Add(1)
	defer gctx.Cleanup.Done()
	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	// rootstore := fsx.DirVirtual(userx.DefaultDataDirectory(userx.DefaultRelRoot()))
	torrentstore := fsx.DirVirtual(stringsx.FirstNonBlank(t.Directory, env.TorrentDir()))
	mediastore := fsx.DirVirtual(env.MediaDir())

	if err := fsx.MkDirs(0700, torrentstore.Path(), mediastore.Path()); err != nil {
		return err
	}

	// async := library.NewAsyncWakeup(gctx.Context)
	// if t.Archive {
	// 	errorsx.Log(daemons.AutoArchival(gctx.Context, db, mediastore, async, t.Archive))
	// }

	peers := make([]torrent.Peer, 0, 128)
	for _, p := range t.Peer {
		host, port, err := net.SplitHostPort(p)
		if err != nil {
			return errorsx.Wrap(err, "unable to setup torrent client")
		}

		addrs, err := net.DefaultResolver.LookupIP(gctx.Context, "ip4", host)
		if err != nil {
			return errorsx.Wrap(err, "unable to resolve host")
		}

		peers = append(peers, torrent.Peer{
			IP:      addrs[0],
			Port:    langx.Must(strconv.Atoi(port)),
			Trusted: true,
		})
	}

	if t.TorrentPrivate {
		log.Println("disabling public networks for torrent")
		firewall = torrent.ClientConfigFirewall(connections.NewFirewall(
			connections.Private{},
			connections.BanInvalidPort{},
			connections.NewBloomBanIP(10*time.Minute),
		))
	}

	var torrentlogging logging = torrent.LogDiscard()
	if envx.Boolean(false, env.TorrentLogging) {
		torrentlogging = log.New(os.Stderr, "[torrent] ", log.Flags())
	}
	tm := dht.DefaultMuxer().
		Method(bep0051.Query, bep0051.NewEndpoint(bep0051.EmptySampler{}))
	tstore := blockcache.NewTorrentFromVirtualFS(torrentstore)

	torconfig := torrent.NewDefaultClientConfig(
		torrent.NewMetadataCache(torrentstore.Path()),
		tstore,
		torrent.ClientConfigCacheDirectory(torrentstore.Path()),
		torrent.ClientConfigDisableDynamicIP,
		torrent.ClientConfigPeerID(int160.FromByteArray(peerid).String()),
		torrent.ClientConfigPEX(false),
		torrent.ClientConfigSeed(false),
		torrent.ClientConfigPortForward(true),
		torrent.ClientConfigInfoLogger(torrentlogging),
		torrent.ClientConfigDebugLogger(torrentlogging),
		torrent.ClientConfigMuxer(tm),
		torrent.ClientConfigBucketLimit(256),
		torrent.ClientConfigHTTPUserAgent("retrovibed/0.0"),
		torrent.ClientConfigConnectionClosed(func(ih metainfo.Hash, stats torrent.ConnStats, remaining int) {
			if stats.BytesWrittenData.Uint64() == 0 {
				return
			}

			var md tracking.Metadata
			ictx, done := context.WithTimeout(gctx.Context, 3*time.Second)
			defer done()
			if err := tracking.MetadataUploadedByID(ictx, db, ih.Bytes(), stats.BytesWrittenData.Uint64()).Scan(&md); err != nil {
				log.Println(errorsx.Wrapf(err, "%s: unable to record uploaded metrics", ih.String()))
				return
			}

			if remaining == 0 {
				time.AfterFunc(time.Minute, func() {
					log.Println("connection closed, and no remaining connections, TODO gracefully remove")
				})
			}
		}),
		bootstrap,
		firewall,
	)

	if tnetwork, err = torrentx.Autosocket(0); err != nil {
		return errorsx.Wrap(err, "unable to setup torrent socket")
	}

	tclient, err := tnetwork.Bind(torrent.NewClient(torconfig))
	if err != nil {
		return errorsx.Wrap(err, "unable to bind torrent to socket")
	}
	defer tclient.Close()

	importfn := func(ctx context.Context, w workload) error {
		var (
			info *metainfo.Info
		)

		if len(w.meta.InfoBytes) == 0 {
			var (
				cause error
			)
			log.Printf("awaiting torrent info %s\n", w.meta.ID)

			info, cause = tclient.Info(ctx, w.meta, torrent.TunePeers(peers...))
			if cause != nil {
				return errorsx.Wrapf(cause, "failed to retrieve torrent info %s", w.meta.ID)
			}

			log.Println("torrent info received", w.meta.ID.String(), spew.Sdump(w.meta.Metainfo()))
			if w.meta, cause = torrent.NewFromInfo(info); err != nil {
				return errorsx.Wrapf(cause, "failed to retrieve torrent info %s", w.meta.ID)
			}
			if err = os.WriteFile(torrentstore.Path(fmt.Sprintf("%s.torrent", w.meta.ID)), errorsx.Must(metainfo.Encode(w.meta.Metainfo())), 0600); err != nil {
				return errorsx.Wrapf(cause, "failed to record torrent %s %v", w.meta.ID, cause)
			}
		} else {
			if _info, cause := w.meta.Metainfo().UnmarshalInfo(); cause != nil {
				return errorsx.Wrapf(cause, "failed to resume torrent %s", w.meta.ID)
			} else {
				info = &_info
			}

			log.Printf("torrent info available resuming %s - %s - %d\n", w.meta.ID, info.Name, len(w.meta.InfoBytes))
		}

		lmd := tracking.NewMetadata(
			&w.meta.ID,
			tracking.MetadataOptionFromInfo(info),
			tracking.MetadataOptionTrackers(w.meta.Trackers...),
			tracking.MetadataOptionAutoArchive(t.Archive),
			tracking.MetadataOptionAutoDescription,
		)

		if cause := tracking.MetadataInsertWithDefaults(ctx, db, lmd).Scan(&lmd); cause != nil {
			return errorsx.Wrapf(cause, "failed to record metadata %s", w.meta.ID.String())
		}

		if err := tracking.MetadataDownloadByID(ctx, db, lmd.ID).Scan(&lmd); err != nil {
			return errorsx.Wrap(err, "unable to track download")
		}

		// dctx, done := context.WithCancel(ctx)
		// defer done()
		// if cause := tracking.Download(dctx, db, rootstore, &lmd, dl); cause != nil {
		// 	return errorsx.Wrapf(cause, "failed to download %s %v", w.meta.ID.String(), cause)
		// }

		// if t.Archive {
		// 	async.Broadcast()
		// }

		return nil
	}

	arena := asynccompute.New(func(ctx context.Context, w workload) error {
		if err := importfn(ctx, w); err != nil {
			fmt.Println(w.magnet)
			return err
		}

		return nil
	})

	for k, v := range t.torrents(torrentstore) {
		if err := arena.Run(gctx.Context, workload{magnet: k, meta: v}); err != nil {
			return errorsx.Compact(err, asynccompute.Shutdown(gctx.Context, arena))
		}
	}

	if err = asynccompute.Shutdown(gctx.Context, arena); err != nil {
		return err
	}

	// log.Println("SHUTTING DOWN ASYNC ARCHIVAL INITIATED")
	// defer log.Println("SHUTTING DOWN ASYNC ARCHIVAL COMPLETED")
	// return async.Close()
	return nil
}
