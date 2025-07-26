package daemons

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"runtime"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/justinas/alice"
	"golang.org/x/crypto/ssh"
	"golang.org/x/time/rate"
	"golang.zx2c4.com/wireguard/tun/netstack"

	"github.com/james-lawrence/torrent/connections"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/blockcache"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/downloads"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/dhtx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/netx"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/internal/tlsx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/meta/identityssh"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/tracking"

	_ "github.com/marcboeker/go-duckdb/v2"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/bep0051"

	"github.com/gorilla/mux"
)

type logging interface {
	Println(v ...interface{})
	Printf(format string, v ...interface{})
	Print(v ...interface{})
}

type Command struct {
	DisableMDNS        bool             `flag:"" name:"no-mdns" help:"disable the multicast dns service" env:"${env_mdns_disabled}"`
	AutoBootstrap      bool             `flag:"" name:"auto-bootstrap" help:"bootstrap from a predefined set of peers" env:"${env_auto_bootstrap}"`
	AutoDiscovery      bool             `flag:"" name:"auto-discovery" help:"EXPERIMENTAL: enable automatic discovery of content from peers" env:"${env_auto_discovery}"`
	AutoDownload       bool             `flag:"" name:"auto-download" help:"EXPERIMENTAL: enable automatically downloading torrent from the downloads folder"`
	AutoIdentifyMedia  bool             `flag:"" name:"auto-identify-media" help:"EXPERIMENTAL: enable automatically identifying media" env:"${env_auto_identify_media}"`
	AutoArchive        bool             `flag:"" name:"auto-archive" help:"enable automatic archiving of eligible media" negatable:"" env:"${env_auto_archive}"`
	AutoReclaim        bool             `flag:"" name:"auto-reclaim" help:"EXPERIMENTAL: enable automatic reclaiming of disk space of archived media" negatable:"" env:"${env_auto_reclaim}"`
	TorrentResume      bool             `flag:"" name:"torrent-resume" help:"enable announcing and resuming torrents" negatable:"" default:"true"`
	TorrentPrivate     bool             `flag:"" name:"torrent-private" help:"restrict torrent connections to private networks" env:"${env_torrent_private}"`
	TorrentPort        uint16           `flag:"" name:"torrent-port" help:"port to use for torrenting" env:"${env_torrent_port}" default:"10000"`
	TorrentPublicIP4   string           `flag:"" name:"torrent-ipv4" help:"public ipv4 address of the torrent" env:"${env_torrent_ipv4}"`
	TorrentPublicIP6   string           `flag:"" name:"torrent-ipv6" help:"public ipv6 address of the torrent" env:"${env_torrent_ipv6}"`
	TorrentMaxRequests uint32           `flag:"" name:"torrent-max-outstanding" help:"maximum piece requests to allow" default:"1024"`
	HTTP               cmdopts.Listener `flag:"" name:"http-address" help:"address to serve daemon api from" default:"tcp://:9998" env:"${env_daemon_socket}"`
	SelfSignedHosts    []string         `flag:"" name:"self-signed-hosts" help:"comma seperated list of hosts to add to the sign signed certificate" env:"${env_self_signed_hosts}"`
}

func (t *Command) BeforeApply() error {
	t.AutoReclaim = true
	t.TorrentResume = true
	return nil
}

func (t Command) Run(gctx *cmdopts.Global, sshid *cmdopts.SSHID) (err error) {
	var (
		db           *sql.DB
		id           ssh.Signer
		torrentpeers                            = userx.DefaultCacheDirectory(userx.DefaultRelRoot(), "torrent.peers")
		bootstrap    torrent.ClientConfigOption = torrent.ClientConfigNoop
		firewall     torrent.ClientConfigOption = torrent.ClientConfigNoop
		dynamicip    torrent.ClientConfigOption = torrent.ClientConfigNoop
		tnetwork     torrent.Binder
		wgnet        *netstack.Net
		deepjwt      *http.Client = &http.Client{}
	)

	// envx.Debug(os.Environ()...)

	if id, err = sshid.Signer(); err != nil {
		return err
	}

	var (
		peerid = krpc.IdFromString(md5x.String(ssh.FingerprintSHA256(id.PublicKey())))
	)

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

	gctx.Cleanup.Add(1)
	defer gctx.Cleanup.Done()
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

	if t.TorrentPrivate {
		log.Println("disabling public networks for torrent")
		firewall = torrent.ClientConfigFirewall(connections.NewFirewall(
			connections.Private{},
			connections.BanInvalidPort{},
			connections.NewBloomBanIP(10*time.Minute),
		))
	}

	rootstore := fsx.DirVirtual(env.RootStorageDir())
	mediastore := fsx.DirVirtual(env.MediaDir())
	tvfs := fsx.DirVirtual(env.TorrentDir())

	if err := fsx.MkDirs(0700, rootstore.Path(), mediastore.Path(), tvfs.Path(), wireguardx.ConfigDirectory()); err != nil {
		return err
	}

	var tstore storage.ClientImpl = blockcache.NewTorrentFromVirtualFS(tvfs)

	if t.AutoReclaim {
		errorsx.Log(AutoReclaim(gctx.Context, db, mediastore, library.NewAsyncWakeup(gctx.Context)))
	} else {
		log.Println("automatic disk reclaim is disabled", envx.Boolean(t.AutoReclaim, env.AutoReclaim))
	}

	if t.AutoArchive {
		if err := metaapi.Register(gctx.Context); err != nil {
			return errorsx.Wrap(err, "unable to register with archival service")
		}

		errorsx.Log(AutoArchival(gctx.Context, db, mediastore, library.NewAsyncWakeup(gctx.Context), t.AutoReclaim))
		c, err := metaapi.AutoJWTClient(gctx.Context)
		if err != nil {
			return errorsx.Wrap(err, "failed to create oauth2 http client for archival")
		}
		deepjwt = c
		tstore = library.NewTorrentStorage(deepjwt, db, tstore)
	} else {
		log.Println("automatic media archival is disabled")
	}

	log.Printf("USING STORAGE %T - %s\n", tstore, tvfs.Path())

	tm := dht.DefaultMuxer().
		Method(bep0051.Query, bep0051.NewEndpoint(bep0051.EmptySampler{}))

	if path := wireguardx.Latest(); fsx.Exists(path) && !t.TorrentPrivate {
		wcfg, err := wireguardx.Parse(path)
		if err != nil {
			return errorsx.Wrapf(err, "unable to parse wireguard configuration: %s", path)
		}

		log.Println("loaded wireguard configuration", path)

		if wgnet, tnetwork, err = torrentx.WireguardSocket(wcfg, t.TorrentPort); err != nil {
			return errorsx.Wrap(err, "unable to setup wireguard torrent socket")
		}

		dynamicip = torrentx.DynamicIP(wcfg, wgnet, t.TorrentPort)
	} else {
		log.Println("no wireguard configuration found at", path, wgnet == nil)
	}

	var torrentlogging logging = torrent.LogDiscard()
	if envx.Boolean(false, env.TorrentLogging) {
		torrentlogging = log.New(os.Stderr, "[torrent] ", log.Flags())
	}

	torconfig := torrent.NewDefaultClientConfig(
		torrent.NewMetadataCache(tvfs.Path()),
		tstore,
		torrent.ClientConfigCacheDirectory(tvfs.Path()),
		torrent.ClientConfigPeerID(string(peerid[:])),
		torrent.ClientConfigIPv4(t.TorrentPublicIP4),
		torrent.ClientConfigIPv6(t.TorrentPublicIP6),
		torrent.ClientConfigPEX(envx.Boolean(true, env.TorrentPEX)),
		torrent.ClientConfigSeed(envx.Boolean(true, env.TorrentAllowSeeding)),
		torrent.ClientConfigDialer(DefaultDialer(wgnet)),
		torrent.ClientConfigInfoLogger(torrentlogging),
		torrent.ClientConfigDebugLogger(torrentlogging),
		torrent.ClientConfigMuxer(tm),
		torrent.ClientConfigBucketLimit(256),
		torrent.ClientConfigDialPoolSize(runtime.NumCPU()),
		torrent.ClientConfigDialRateLimit(rate.NewLimiter(rate.Limit(32), runtime.NumCPU())),
		// torrent.ClientConfigAcceptLimit(rate.NewLimiter(rate.Limit(runtime.NumCPU()), runtime.NumCPU()*4)),
		torrent.ClientConfigAcceptLimit(rate.NewLimiter(rate.Inf, 1)),
		torrent.ClientConfigMaxOutstandingRequests(int(t.TorrentMaxRequests)),
		torrent.ClientConfigPeerLimits(runtime.NumCPU()/2, runtime.NumCPU()),
		torrent.ClientConfigUploadLimit(rate.NewLimiter(rate.Limit(256*bytesx.MiB), 256*bytesx.MiB)),
		torrent.ClientConfigHTTPUserAgent("retrovibed/0.0"),
		torrent.ClientConfigConnectionClosed(func(ih metainfo.Hash, stats torrent.ConnStats, remaining int) {
			if stats.BytesWrittenData.Uint64() == 0 {
				return
			}

			var md tracking.Metadata
			ictx, done := context.WithTimeout(context.Background(), 3*time.Second)
			defer done()
			if err := tracking.MetadataUploadedByID(ictx, db, ih.Bytes(), stats.BytesWrittenData.Uint64()).Scan(&md); err != nil {
				log.Println(errorsx.Wrapf(err, "%s: unable to record uploaded metrics", ih.String()))
				return
			}
		}),
		bootstrap,
		firewall,
		dynamicip,
	)

	log.Println("torrent specified public ip:", torconfig.PublicIP4(), torconfig.PublicIP6())

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

	go timex.NowAndEveryVoid(gctx.Context, 10*time.Minute, func(ctx context.Context) {
		errorsx.Log(MediaMetadataImport(gctx.Context, db, tvfs, tstore))
	})

	if t.AutoDiscovery {
		go func() {
			if err := AutoDiscovery(dctx, db, tclient, tstore); err != nil {
				asyncfailure(errorsx.Wrap(err, "autodiscovery from peers failed"))
				return
			}
		}()
	} else {
		log.Println("autodiscovery is disabled, to enable add --auto-discovery flag, this is an experimental feature.")
	}

	go func() {
		if err := DiscoverFromRSSFeeds(dctx, db, rootstore, tclient, tstore); err != nil {
			asyncfailure(errorsx.Wrap(err, "autodiscovery of RSS feeds failed"))
			return
		}
	}()

	go VerifyTorrents(dctx, db, rootstore, tclient, tstore)

	if t.TorrentResume {
		go AnnounceSeeded(dctx, db, rootstore, tclient, tstore)
		go ResumeDownloads(dctx, db, rootstore, tclient, tstore)
	} else {
		log.Println("announce/resume disabled")
	}

	if t.AutoIdentifyMedia {
		go timex.NowAndEvery(gctx.Context, 15*time.Minute, func(ctx context.Context) error {
			errorsx.Log(IdentifyTorrentyMedia(dctx, db))
			return nil
		})
	} else {
		log.Println("auto identify media is disabled, to enable add --auto-identify-media flag, this is an experimental feature.")
	}

	if err = PublicIP(dctx, DefaultDialer(wgnet)); err != nil {
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
	media.NewHTTPLibrary(db, mediastore, deepjwt).Bind(httpmux.PathPrefix("/m").Subrouter())
	media.NewHTTPDiscovered(db, tclient, tstore, media.HTTPDiscoveredOptionRootStorage(rootstore)).Bind(httpmux.PathPrefix("/d").Subrouter())
	media.NewHTTPRSSFeed(db).Bind(httpmux.PathPrefix("/rss").Subrouter())
	media.NewHTTPKnown(db).Bind(httpmux.PathPrefix("/k").Subrouter())

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
	if cause := http.ServeTLS(httpbind, httpmux, tlspem, tlspem); netx.IgnoreConnectionClosed(cause) != nil {
		return errorsx.Wrap(cause, "http server stopped")
	}

	// report any async failures.
	return contextx.IgnoreCancelled(errorsx.Compact(context.Cause(dctx), dctx.Err()))
}
