package daemons

import (
	"context"
	"database/sql"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/justinas/alice"
	"golang.org/x/crypto/ssh"
	"golang.zx2c4.com/wireguard/tun/netstack"

	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/downloads"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/dhtx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/internal/tlsx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta/identityssh"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/tracking"

	_ "github.com/marcboeker/go-duckdb/v2"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/bep0051"

	"github.com/gorilla/mux"
)

type Command struct {
	DisableMDNS       bool             `flag:"" name:"no-mdns" help:"disable the multicast dns service" default:"false" env:"${env_mdns_disabled}"`
	AutoBootstrap     bool             `flag:"" name:"auto-bootstrap" help:"bootstrap from a predefined set of peers" default:"true" env:"${env_auto_bootstrap}"`
	AutoDiscovery     bool             `flag:"" name:"auto-discovery" help:"enable autodiscovery of content from peers" default:"false" env:"${env_auto_discovery}"`
	AutoDownload      bool             `flag:"" name:"auto-download" help:"enable automatically downloading torrent from the downloads folder" default:"false"`
	AutoIdentifyMedia bool             `flag:"" name:"auto-identify-media" help:"enable automatically identifying media - EXPERIMENTAL" default:"false"`
	HTTP              cmdopts.Listener `flag:"" name:"http-address" help:"address to serve daemon api from" default:"tcp://:9998" env:"${env_daemon_socket}"`
	SelfSignedHosts   []string         `flag:"" name:"self-signed-hosts" help:"comma seperated list of hosts to add to the sign signed certificate" env:"${env_self_signed_hosts}"`
	TorrentPort       int              `flag:"" name:"torrent-port" help:"port to use for torrenting" env:"${env_torrent_port}" default:"10000"`
}

func (t Command) Run(gctx *cmdopts.Global, id *cmdopts.SSHID) (err error) {
	var (
		db           *sql.DB
		torrentpeers                            = userx.DefaultCacheDirectory(userx.DefaultRelRoot(), "torrent.peers")
		peerid                                  = krpc.IdFromString(ssh.FingerprintSHA256(id.PublicKey()))
		bootstrap    torrent.ClientConfigOption = torrent.ClientConfigNoop
		tnetwork     torrent.Binder
		wgnet        *netstack.Net
	)

	// envx.Debug(os.Environ()...)

	sshjwt := jwtx.NewSSHSigner()
	jwt.RegisterSigningMethod(sshjwt.Alg(), func() jwt.SigningMethod { return sshjwt })
	jwtx.RegisterAlgorithms(sshjwt, jwt.SigningMethodHS512)

	dctx, done := context.WithCancelCause(gctx.Context)
	asyncfailure := func(cause error) {
		done(contextx.IgnoreCancelled(cause))
	}
	defer asyncfailure(nil)

	httpbind, err := t.HTTP.Socket()
	if err != nil {
		return errorsx.Wrap(err, "unable to setup http socket")
	}
	go func() {
		<-dctx.Done()
		httpbind.Close()
	}()

	if db, err = cmdmeta.Database(dctx); err != nil {
		return err
	}
	defer db.Close()

	if err = identityssh.ImportPublicKey(dctx, db, id.PublicKey()); err != nil {
		return errorsx.Wrap(err, "unable to import ssh identity")
	}

	go func() {
		errorsx.Log(errorsx.Wrap(PrepareDefaultFeeds(dctx, db), "unable to initialize default rss feeds"))
	}()

	if fsx.IsRegularFile(torrentpeers) {
		bootstrap = torrent.ClientConfigBootstrapPeerFile(torrentpeers)
	}

	if t.AutoBootstrap {
		log.Println("public bootstrap enabled")
		bootstrap = torrent.ClientConfigBootstrapGlobal
	}

	rootstore := fsx.DirVirtual(userx.DefaultDataDirectory(userx.DefaultRelRoot()))
	mediastore := fsx.DirVirtual(env.MediaDir())
	torrentstore := fsx.DirVirtual(env.TorrentDir())

	// tstore := blockcache.NewTorrentFromVirtualFS(mediastore)
	torrentdir := env.TorrentDir()
	tstore := storage.NewFile(torrentdir, storage.FileOptionPathMakerInfohash)

	tm := dht.DefaultMuxer().
		Method(bep0051.Query, bep0051.NewEndpoint(bep0051.EmptySampler{}))

	torconfig := torrent.NewDefaultClientConfig(
		torrent.NewMetadataCache(torrentstore.Path()),
		tstore,
		torrent.ClientConfigPeerID(string(peerid[:])),
		torrent.ClientConfigSeed(true),
		torrent.ClientConfigInfoLogger(log.New(io.Discard, "[torrent] ", log.Flags())),
		torrent.ClientConfigMuxer(tm),
		torrent.ClientConfigBucketLimit(32),
		torrent.ClientConfigHTTPUserAgent("retrovibed/0.0"),
		torrent.ClientConfigConnectionClosed(func(ih metainfo.Hash, stats torrent.ConnStats) {
			if stats.BytesWrittenData.Uint64() == 0 {
				return
			}

			var md tracking.Metadata
			ictx, done := context.WithTimeout(context.Background(), 3*time.Second)
			defer done()
			if err := tracking.MetadataUploadedByID(ictx, db, ih.Bytes(), stats.BytesWrittenData.Uint64()).Scan(&md); err != nil {
				log.Println(errorsx.Wrapf(err, "%s: unable to record uploaded metrics", ih.HexString()))
				return
			}
		}),
		// func(t *torrent, stats ConnStats) {
		// log.Println("connection closed", t.md.ID.HexString(), stats.BytesReadUsefulData.Int64(), stats.BytesWrittenData.Int64())
		// }
		bootstrap,
	)

	if path := wireguardx.Latest(); fsx.Exists(path) {
		wcfg, err := wireguardx.Parse(path)
		if err != nil {
			return errorsx.Wrapf(err, "unable to parse wireguard configuration: %s", path)
		}

		log.Println("loaded wireguard configuration", path)

		if wgnet, tnetwork, err = torrentx.WireguardSocket(wcfg, t.TorrentPort); err != nil {
			return errorsx.Wrap(err, "unable to setup wireguard torrent socket")
		}
	} else {
		log.Println("no wireguard configuration found at", path)
	}

	if tnetwork == nil {
		if tnetwork, err = torrentx.Autosocket(t.TorrentPort); err != nil {
			return errorsx.Wrap(err, "unable to setup torrent socket")
		}
	}

	tclient, err := tnetwork.Bind(torrent.NewClient(torconfig))
	if err != nil {
		return errorsx.Wrap(err, "unable to setup torrent client")
	}

	if t.AutoDownload {
		dwatcher, err := downloads.NewDirectoryWatcher(dctx, db, rootstore, tclient, tstore)
		if err != nil {
			return errorsx.Wrap(err, "unable to setup directory monitoring for torrents")
		}

		if err = dwatcher.Add(userx.DefaultDownloadDirectory()); err != nil {
			return errorsx.Wrap(err, "unable to add the download directory to be watched")
		}
	} else {
		log.Println("download folder monitoring disabled")
	}

	{
		current, _ := slicesx.First(tclient.DhtServers()...)
		if peers, err := current.AddNodesFromFile(torrentpeers); err == nil {
			log.Println("added peers", peers)
		} else {
			log.Println("unable to read peers", err)
		}
	}

	for _, d := range tclient.DhtServers() {
		go dhtx.RecordBootstrapNodes(dctx, time.Minute, d, torrentpeers)
		go d.TableMaintainer()
		go d.Bootstrap(dctx)
	}

	go PrintStatistics(dctx, db)

	// block for first refresh
	errorsx.Log(cmdmeta.RefreshFTS(gctx.Context, db))
	go timex.Every(10*time.Minute, func() {
		errorsx.Log(cmdmeta.RefreshFTS(gctx.Context, db))
	})

	if t.AutoDiscovery {
		go func() {
			if err := AutoDiscovery(dctx, db, tclient, tstore); err != nil {
				asyncfailure(errorsx.Wrap(err, "autodiscovery from peers failed"))
				return
			}
		}()
	} else {
		log.Println("autodiscovery is disabled, to enable add --auto-discovery flag, this is an alpha feature.")
	}

	go func() {
		if err := DiscoverFromRSSFeeds(dctx, db, rootstore, tclient, tstore); err != nil {
			asyncfailure(errorsx.Wrap(err, "autodiscovery of RSS feeds failed"))
			return
		}
	}()

	go AnnounceSeeded(dctx, db, rootstore, tclient, tstore)
	go ResumeDownloads(dctx, db, rootstore, tclient, tstore)
	if t.AutoIdentifyMedia {
		go timex.NowAndEvery(gctx.Context, 15*time.Minute, func(ctx context.Context) error {
			errorsx.Log(IdentifyTorrentyMedia(dctx, db))
			return nil
		})
	}

	if err = VPNIP(dctx, wgnet); err != nil {
		log.Println("failed to lookup wireguard ip", err)
	}

	if err = VPNReload(dctx, tnetwork, tclient, torconfig, t.TorrentPort); err != nil {
		return err
	} else {
		log.Println("wireguard watching", wireguardx.Latest())
	}

	httpmux := mux.NewRouter()
	httpmux.NotFoundHandler = httpx.NotFound(alice.New())
	httpmux.Use(
		httpx.RouteInvoked,
		httpx.Chaos(
			envx.Float64(0.0, env.ChaosRate),
			httpx.ChaosStatusCodes(http.StatusBadGateway),
			httpx.ChaosRateLimited(time.Second),
		),
	)

	httpmux.HandleFunc(
		"/healthz",
		httpx.Healthz(
			cmdopts.MachineID(),
			envx.Float64(0.0, env.HTTPHealthzProbability),
			envx.Int(http.StatusOK, env.HTTPHealthzCode),
		),
	).Methods(http.MethodGet)

	oauth2mux := httpmux.PathPrefix("/oauth2").Subrouter()
	metaapi.NewSSHOauth2(db).Bind(oauth2mux.PathPrefix("/ssh").Subrouter())

	metamux := httpmux.PathPrefix("/meta").Subrouter()

	metaapi.NewHTTPWireguard(wireguardx.ConfigDirectory()).Bind(httpmux.PathPrefix("/wireguard").Subrouter())
	metaapi.NewHTTPUsermanagement(db).Bind(metamux.PathPrefix("/u12t").Subrouter())
	metaapi.NewHTTPDaemons(db).Bind(metamux.PathPrefix("/d").Subrouter())
	metaapi.NewHTTPAuthz(db).Bind(metamux.PathPrefix("/authz").Subrouter())
	media.NewHTTPLibrary(db, mediastore).Bind(httpmux.PathPrefix("/m").Subrouter())
	media.NewHTTPDiscovered(db, tclient, tstore, media.HTTPDiscoveredOptionTorrentStorage(torrentstore)).Bind(httpmux.PathPrefix("/d").Subrouter())
	media.NewHTTPRSSFeed(db).Bind(httpmux.PathPrefix("/rss").Subrouter())

	tlspem := envx.String(userx.DefaultCacheDirectory(userx.DefaultRelRoot(), "tls.pem"), env.DaemonTLSPEM)
	if err = tlsx.SelfSignedLocalHostTLS(tlspem, tlsx.X509OptionHosts(t.SelfSignedHosts...)); err != nil {
		return err
	}

	_ = httpmux.Walk(func(route *mux.Route, router *mux.Router, ancestors []*mux.Route) error {
		if uri, err := route.URLPath(); err == nil {
			log.Println("Route", errorsx.Zero(route.GetPathTemplate()), errorsx.Zero(route.GetMethods()), uri.String())
		}

		return nil
	})

	if t.DisableMDNS {
		log.Println("mdns service is disabled")
	} else {
		if err := MulticastService(dctx, httpbind); err != nil {
			return errorsx.Wrap(err, "unable to setup multicast service")
		}
	}

	log.Println("https listening on:", httpbind.Addr().String(), tlspem)
	if cause := http.ServeTLS(httpbind, httpmux, tlspem, tlspem); cause != nil {
		return errorsx.Wrap(cause, "http server stopped")
	}

	// report any async failures.
	return errorsx.Compact(context.Cause(dctx), dctx.Err())
}
