package daemons

import (
	"context"
	"log"
	"path/filepath"

	"github.com/fsnotify/fsnotify"
	"github.com/james-lawrence/torrent"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsnotifyx"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"
)

func ReloadVPN(ctx context.Context, tnetwork torrent.Binder, tclient *torrent.Client, torconfig *torrent.ClientConfig, port int) error {
	var previous = errorsx.Zero(filepath.EvalSymlinks(wireguardx.Latest()))

	return errorsx.Wrap(fsnotifyx.OnceAndOnChange(ctx, wireguardx.Latest(), func(ictx context.Context, evt fsnotify.Event) error {
		log.Println("wireguard configuration event initiated", evt.Name, evt.Op)
		defer log.Println("wireguard configuration event completed", evt.Name, evt.Op)

		switch evt.Op {
		case fsnotify.Remove:
		default:
			if previous == errorsx.Zero(filepath.EvalSymlinks(wireguardx.Latest())) {
				log.Println("vpn configuration unchanged")
				return nil
			}

			wcfg, err := wireguardx.Parse(evt.Name)
			if err != nil {
				return errorsx.Wrap(err, "unable to parse wireguard config")
			}

			if tnetwork, err = torrentx.WireguardSocket(wcfg, port); err != nil {
				return errorsx.Wrap(err, "unable to setup wireguard torrent socket")
			}
			nclient, err := tnetwork.Bind(torrent.NewClient(torconfig))
			if err != nil {
				return errorsx.Wrap(err, "unable to setup torrent client")
			}
			tclient.Close()
			tclient = nclient
		}
		return nil
	}), "unable setup wireguard monitoring")
}
