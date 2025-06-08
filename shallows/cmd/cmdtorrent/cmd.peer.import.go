package cmdtorrent

import (
	"bufio"
	"io"
	"iter"
	"log"
	"net"
	"os"
	"strconv"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/bep0051"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"golang.org/x/crypto/ssh"
)

type importPeer struct {
	Peer      string `flag:"" name:"peer" help:"peer to connect to and download the provided torrents from" default:"localhost:10000"`
	Directory string `flag:"" name:"directory" help:"specify the directory to download torrents into" default:""`
	Magnets   string `arg:"" name:"magnets" help:"file containing magnet links to download, defaults to stdin" default:""`
}

func (t importPeer) torrents() iter.Seq[torrent.Metadata] {
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
		peerid    = krpc.IdFromString(ssh.FingerprintSHA256(id.PublicKey()))
		tnetwork  torrent.Binder
		bootstrap torrent.ClientConfigOption = torrent.ClientConfigNoop
	)

	torrentstore := fsx.DirVirtual(stringsx.FirstNonBlank(t.Directory, env.TorrentDir()))

	if err := fsx.MkDirs(0700, torrentstore.Path()); err != nil {
		return err
	}

	host, port, err := net.SplitHostPort(t.Peer)
	if err != nil {
		return errorsx.Wrap(err, "unable to setup torrent client")
	}

	tm := dht.DefaultMuxer().
		Method(bep0051.Query, bep0051.NewEndpoint(bep0051.EmptySampler{}))
	tstore := blockcache.NewTorrentFromVirtualFS(torrentstore)

	torconfig := torrent.NewDefaultClientConfig(
		torrent.NewMetadataCache(torrentstore.Path()),
		tstore,
		torrent.ClientConfigPeerID(string(peerid[:])),
		torrent.ClientConfigPortForward(true),
		torrent.ClientConfigSeed(false),
		torrent.ClientConfigInfoLogger(log.New(io.Discard, "[torrent] ", log.Flags())),
		torrent.ClientConfigMuxer(tm),
		torrent.ClientConfigBucketLimit(32),
		torrent.ClientConfigHTTPUserAgent("retrovibed/0.0"),
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
		IP:      net.ParseIP(host),
		Port:    langx.Must(strconv.Atoi(port)),
		Trusted: true,
	}

	for u := range t.torrents() {
		dl, _, cause := tclient.Start(u, torrent.TunePeers(sourcepeer), torrent.TuneAutoDownload)
		if cause != nil {
			log.Println("failed to start magnet", u.ID.HexString(), cause)
			err = errorsx.Compact(err, cause)
			continue
		}

		if _, cause := torrent.DownloadInto(gctx.Context, io.Discard, dl); cause != nil {
			log.Println("failed to download", u.ID.HexString(), cause)
			err = errorsx.Compact(err, cause)
			continue
		}
	}

	return nil
}
