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
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/asynccompute"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/tracking"
	"golang.org/x/crypto/ssh"
)

type importPeer struct {
	Peer      string `flag:"" name:"peer" help:"peer to connect to and download the provided torrents from" default:"localhost:10000"`
	Directory string `flag:"" name:"directory" help:"specify the directory to download torrents into" default:""`
	Magnets   string `arg:"" name:"magnets" help:"file containing magnet links to download, defaults to stdin" default:""`
}

func (t importPeer) torrents(tstore fsx.Virtual) iter.Seq[torrent.Metadata] {
	return func(yield func(torrent.Metadata) bool) {
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

			if !yield(magnet) {
				return
			}
		}

		if err := s.Err(); err != nil {
			log.Fatalln(err)
		}
	}
}

func (t importPeer) Run(gctx *cmdopts.Global, id *cmdopts.SSHID) (err error) {

	var (
		db        *sql.DB
		peerid    = krpc.IdFromString(md5x.String(ssh.FingerprintSHA256(id.PublicKey())))
		tnetwork  torrent.Binder
		bootstrap torrent.ClientConfigOption = torrent.ClientConfigNoop
	)

	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	rootstore := fsx.DirVirtual(userx.DefaultDataDirectory(userx.DefaultRelRoot()))
	torrentstore := fsx.DirVirtual(stringsx.FirstNonBlank(t.Directory, env.TorrentDir()))

	if err := fsx.MkDirs(0700, torrentstore.Path()); err != nil {
		return err
	}

	host, port, err := net.SplitHostPort(t.Peer)
	if err != nil {
		return errorsx.Wrap(err, "unable to setup torrent client")
	}

	addrs, err := net.DefaultResolver.LookupIP(gctx.Context, "ip4", host)
	if err != nil {
		return errorsx.Wrap(err, "unable to resolve host")
	}

	// log.Println("DERP", ssh.FingerprintSHA256(id.PublicKey()), "->", int160.FromByteArray(peerid).String())
	// log.Println("WAAAT", addrs)

	tm := dht.DefaultMuxer().
		Method(bep0051.Query, bep0051.NewEndpoint(bep0051.EmptySampler{}))
	tstore := blockcache.NewTorrentFromVirtualFS(torrentstore)

	torconfig := torrent.NewDefaultClientConfig(
		torrent.NewMetadataCache(torrentstore.Path()),
		tstore,
		torrent.ClientConfigPeerID(int160.FromByteArray(peerid).String()),
		torrent.ClientConfigPEX(false),
		torrent.ClientConfigSeed(false),
		torrent.ClientConfigPortForward(true),
		// torrent.ClientConfigInfoLogger(log.New(os.Stderr, "[torrent] ", log.Flags())),
		// torrent.ClientConfigDebugLogger(log.New(os.Stderr, "[torrent-debug] ", log.Flags())),
		torrent.ClientConfigMuxer(tm),
		torrent.ClientConfigBucketLimit(32),
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
	)

	if tnetwork, err = torrentx.Autosocket(0); err != nil {
		return errorsx.Wrap(err, "unable to setup torrent socket")
	}

	tclient, err := tnetwork.Bind(torrent.NewClient(torconfig))
	if err != nil {
		return errorsx.Wrap(err, "unable to bind torrent to socket")
	}

	sourcepeer := torrent.Peer{
		IP:      addrs[0],
		Port:    langx.Must(strconv.Atoi(port)),
		Trusted: true,
	}

	arena := asynccompute.New(func(ctx context.Context, meta torrent.Metadata) error {
		var (
			info *metainfo.Info
		)

		if len(meta.InfoBytes) == 0 {
			var (
				cause error
			)
			log.Printf("awaiting torrent info %s\n", meta.ID)

			info, cause = tclient.Info(ctx, meta, torrent.TunePeers(sourcepeer))
			if cause != nil {
				return errorsx.Wrapf(cause, "failed to retrieve torrent info %s", meta.ID)
			}

			log.Println("torrent info received", meta.ID.String(), spew.Sdump(meta.Metainfo()))
			if meta, cause = torrent.NewFromInfo(info); err != nil {
				return errorsx.Wrapf(cause, "failed to retrieve torrent info %s", meta.ID)
			}
			if err = os.WriteFile(torrentstore.Path(fmt.Sprintf("%s.torrent", meta.ID)), errorsx.Must(metainfo.Encode(meta.Metainfo())), 0600); err != nil {
				return errorsx.Wrapf(cause, "failed to record torrent %s %v", meta.ID, cause)
			}
		} else {
			log.Printf("torrent info available resuming %s %d\n", meta.ID, len(meta.InfoBytes))
			if _info, cause := meta.Metainfo().UnmarshalInfo(); cause != nil {
				return errorsx.Wrapf(cause, "failed to resume torrent %s", meta.ID)
			} else {
				info = &_info
			}
		}

		lmd := tracking.NewMetadata(
			&meta.ID,
			tracking.MetadataOptionFromInfo(info),
			tracking.MetadataOptionTrackers(meta.Trackers...),
			tracking.MetadataOptionAutoDescription,
		)

		if cause := tracking.MetadataInsertWithDefaults(ctx, db, lmd).Scan(&lmd); cause != nil {
			return errorsx.Wrapf(cause, "failed to record metadata %s", meta.ID.String())
		}

		dl, _, cause := tclient.Start(meta, torrent.TuneVerifyFull, torrent.TunePeers(sourcepeer), torrent.TuneAutoDownload, torrent.TuneDisableTrackers)
		if cause != nil {
			return errorsx.Wrapf(cause, "failed to start magnet %s - %T: %+v\n", meta.ID.String(), cause, cause)
		}

		if cause := tracking.Download(ctx, db, rootstore, &lmd, dl); cause != nil {
			return errorsx.Wrapf(cause, "failed to download %s %v", meta.ID.String(), cause)
		}

		return nil
	})

	for meta := range t.torrents(torrentstore) {
		if err := arena.Run(gctx.Context, meta); err != nil {
			return errorsx.Compact(err, asynccompute.Shutdown(gctx.Context, arena))
		}
	}

	return asynccompute.Shutdown(gctx.Context, arena)
}
