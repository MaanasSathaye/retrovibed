package env

import (
	"path/filepath"
	"sync"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/userx"
)

const (
	// percentage of requests that should fail.
	ChaosRate = "RETROVIBED_CHAOS_RATE"

	// health code config
	HTTPHealthzProbability = "RETROVIBED_PROBABILITY"
	HTTPHealthzCode        = "RETROVIBED_HEALTHZ_CODE"

	// TLS pem location.
	DaemonTLSPEM = "RETROVIBED_TLS_PEM"
	DaemonSocket = "RETROVIBED_DAEMON_SOCKET" // specify the socket/port to listen on in the form: tcp://:9998

	// JWTSharedSecret used to create jwt tokens
	JWTSharedSecret = "RETROVIBED_JWT_SECRET"

	// enable multicast service discovery
	MDNSDisabled            = "RETROVIBED_MDNS_DISABLED"                    // enable/disable multicast dns registration, allows for the frontend to automatically find daemons on the local network.
	AutoArchive             = "RETROVIBED_MEDIA_AUTO_ARCHIVE"               // enable/disable automatic archiving of eligible media.
	AutoReclaim             = "RETROVIBED_MEDIA_AUTO_RECLAIM"               // enable/disable automatic reclaiming of disk space for media that has been archived.
	AutoIdentifyMedia       = "RETROVIBED_MEDIA_AUTO_IDENTIFY"              // enable/disable automatically identified media.
	AutoDiscovery           = "RETROVIBED_TORRENT_AUTO_DISCOVERY"           // enable/disable automatically discovering torrents from peers.
	AutoBootstrap           = "RETROVIBED_TORRENT_AUTO_BOOTSTRAP"           // enable/disable the predefined set of public swarms to bootstrap from.
	TorrentPort             = "RETROVIBED_TORRENT_PORT"                     // specify the port to listen to torrents on
	TorrentPublicIP4        = "RETROVIBED_TORRENT_PUBLIC_IP4"               // specify the public ipv4 address the torrent service.
	TorrentPublicIP6        = "RETROVIBED_TORRENT_PUBLIC_IP6"               // specify the public ipv6 address the torrent service.
	TorrentLogging          = "RETROVIBED_TORRENT_LOGGING"                  // enable/disable torrent logging. strconv.ParseBool
	TorrentDisableWireguard = "RETROVIBED_TORRENT_DISABLE_WIREGUARD"        // enable/disable torrent vpn functionality. strconv.ParseBool
	TorrentPEX              = "RETROVIBED_TORRENT_PEX"                      // enable/disable torrent pex functionality. strconv.ParseBool
	TorrentAllowSeeding     = "RETROVIBED_TORRENT_ALLOW_SEEDING"            // enable/disable torrent allow the daemon to seed. strconv.ParseBool
	TorrentDownloadStats    = "RETROVIBED_TORRENT_DOWNLOAD_STATS_FREQUENCY" // adjust the frequency at which download stats are logged. time.Duration format.
	TorrentPrivateNetwork   = "RETROVIBED_TORRENT_PRIVATE"                  // specify that the torrent system should firewall to only private networks.
	SelfSignedHosts         = "RETROVIBED_SELF_SIGNED_HOSTS"                // list of hosts to add to the self signed certificate.
)

var v = sync.OnceValue(func() []byte {
	return []byte(envx.String(
		uuid.Must(uuid.NewV4()).String(),
		JWTSharedSecret,
	))
})

func JWTSecret() []byte {
	return v()
}

func RootStorageDir(rel ...string) string {
	return userx.DefaultDataDirectory(userx.DefaultRelRoot(), filepath.Join(rel...))
}

func MediaDir() string {
	return RootStorageDir("media")
}

func TorrentDir() string {
	return RootStorageDir("torrent")
}

func PrivateKeyPath() string {
	return userx.DefaultConfigDir(userx.DefaultRelRoot(), "id")
}
