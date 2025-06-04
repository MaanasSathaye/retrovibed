package daemons

import (
	"context"
	"io"
	"log"
	"net/http"
	"path/filepath"
	"time"

	"github.com/fsnotify/fsnotify"
	"github.com/james-lawrence/torrent"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsnotifyx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
	"golang.zx2c4.com/wireguard/tun/netstack"
)

func VPNIP(ctx context.Context, wgnet *netstack.Net) error {
	if wgnet == nil {
		return nil
	}

	c := &http.Client{Transport: &http.Transport{
		DialContext:           wgnet.DialContext,
		ForceAttemptHTTP2:     true,
		MaxIdleConns:          100,
		IdleConnTimeout:       90 * time.Second,
		TLSHandshakeTimeout:   10 * time.Second,
		ExpectContinueTimeout: 1 * time.Second,
	}}

	if resp := errorsx.Zero(c.Get("https://icanhazip.com")); resp != nil {
		log.Println("wireguard ip", string(errorsx.Zero(io.ReadAll(resp.Body))))
	}

	return nil
}

func VPNReload(ctx context.Context, tnetwork torrent.Binder, tclient *torrent.Client, torconfig *torrent.ClientConfig, port int) error {
	var previous = errorsx.Zero(filepath.EvalSymlinks(wireguardx.Latest()))

	return errorsx.Wrap(fsnotifyx.OnceAndOnChange(ctx, wireguardx.Latest(), func(ictx context.Context, evt fsnotify.Event) error {
		log.Println("wireguard configuration event initiated", evt.Name, evt.Op)
		defer log.Println("wireguard configuration event completed", evt.Name, evt.Op)

		switch evt.Op {
		case fsnotify.Remove:
		default:
			var (
				wgnet *netstack.Net
			)

			if previous == errorsx.Zero(filepath.EvalSymlinks(wireguardx.Latest())) {
				log.Println("vpn configuration unchanged")
				return nil
			}

			wcfg, err := wireguardx.Parse(evt.Name)
			if err != nil {
				return errorsx.Wrap(err, "unable to parse wireguard config")
			}

			if wgnet, tnetwork, err = torrentx.WireguardSocket(wcfg, port); err != nil {
				return errorsx.Wrap(err, "unable to setup wireguard torrent socket")
			}

			dupped := langx.Clone(*torconfig, torrent.ClientConfigDialer(wgnet))

			nclient, err := tnetwork.Bind(torrent.NewClient(&dupped))
			if err != nil {
				return errorsx.Wrap(err, "unable to setup torrent client")
			}
			tclient.Close()
			tclient = nclient
		}
		return nil
	}), "unable setup wireguard monitoring")
}
