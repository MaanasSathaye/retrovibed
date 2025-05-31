package torrentx

import (
	"errors"
	"fmt"
	"log"
	"net"
	"net/netip"
	"os"

	"github.com/james-lawrence/torrent"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/netx"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"

	"github.com/anacrolix/utp"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/sockets"
	"github.com/james-lawrence/torrent/tracker"

	"golang.zx2c4.com/wireguard/conn"
	"golang.zx2c4.com/wireguard/device"
	"golang.zx2c4.com/wireguard/tun/netstack"
)

func AnnouncerFromClient(c *torrent.Client, d netx.Dialer) tracker.Announce {
	cfg := c.Config()

	return tracker.Announce{
		UserAgent: cfg.HTTPUserAgent,
		ClientIp4: krpc.NewNodeAddrFromIPPort(cfg.PublicIP4, 0),
		ClientIp6: krpc.NewNodeAddrFromIPPort(cfg.PublicIP6, 0),
		Dialer:    d,
	}
}

func Autosocket(p int) (_ torrent.Binder, err error) {
	var (
		s1, s2  sockets.Socket
		tsocket *utp.Socket
	)

	tsocket, err = utp.NewSocket("udp", fmt.Sprintf(":%d", p))
	if err != nil {
		return nil, errorsx.Wrap(err, "unable to open utp socket")
	}

	s1 = sockets.New(tsocket, tsocket)
	if addr, ok := tsocket.Addr().(*net.UDPAddr); ok {
		s, err := net.Listen("tcp", fmt.Sprintf(":%d", addr.Port))
		if err != nil {
			return nil, errorsx.Wrap(err, "unable to open tcp socket")
		}
		s2 = sockets.New(s, &net.Dialer{})
	}

	return torrent.NewSocketsBind(s1, s2), nil
}

func WireguardSocket(wcfg *wireguardx.Config, port int) (_ *netstack.Net, _ torrent.Binder, err error) {
	var (
		s1, s2    sockets.Socket
		utpsocket *utp.Socket
		logger    = device.NewLogger(device.LogLevelError, "")
		// logger    = device.NewLogger(device.LogLevelVerbose, "")
	)

	if port == 0 {
		panic("wireguard sockets require a specified torrent port currently")
	}

	tun, tnet, err := netstack.CreateNetTUN(
		slicesx.MapTransform(func(n netip.Prefix) netip.Addr { return n.Addr() }, wcfg.Interface.Addresses...),
		wcfg.Interface.DNS,
		langx.DefaultIfZero(wireguardx.DefaultMTU, int(wcfg.Interface.MTU)),
	)
	if err != nil {
		return nil, nil, errorsx.Wrap(err, "failed to create network tun device")
	}

	dev := device.NewDevice(tun, conn.NewDefaultBind(), logger)

	for _, ipcset := range wireguardx.FormatIPCSet(wcfg) {
		if err = dev.IpcSet(ipcset); err != nil {
			return nil, nil, errorsx.Wrap(err, "invalid ipcset for peer")
		}
	}

	if err = dev.Up(); err != nil {
		return nil, nil, errorsx.Wrap(err, "network device failed to come up")
	}

	conn, err := tnet.ListenUDP(&net.UDPAddr{Port: port})
	if err != nil {
		return nil, nil, errorsx.Wrap(err, "failed to listen on port")
	}

	if utpsocket, err = utp.NewSocketFromPacketConn(conn); err != nil {
		return nil, nil, errorsx.Wrap(err, "failed to create utp socket")
	}

	s1 = sockets.New(utpsocket, utpsocket)
	if addr, ok := utpsocket.Addr().(*net.UDPAddr); ok {
		s, err := tnet.ListenTCP(&net.TCPAddr{Port: addr.Port})
		if err != nil {
			return nil, nil, errorsx.Wrap(err, "unable to open tcp socket")
		}
		s2 = sockets.New(s, tnet)
	}

	return tnet, torrent.NewSocketsBind(s1, s2), nil
}

func NodesFromReply(ret dht.QueryResult) (retni []krpc.NodeInfo) {
	if err := ret.ToError(); err != nil {
		return nil
	}

	ret.Reply.R.ForAllNodes(func(ni krpc.NodeInfo) {
		retni = append(retni, ni)
	})
	return retni
}

// read the info option from a on disk file
func OptionInfoFromFile(path string) torrent.Option {
	if minfo, err := metainfo.LoadFromFile(path); err == nil {
		return torrent.OptionInfo(minfo.InfoBytes)
	} else if !errors.Is(err, os.ErrNotExist) {
		log.Println("unable to load torrent info, will attempt to locate it from peers", err)
	}

	return torrent.OptionNoop
}

func OptionTracker(tracker string) torrent.Option {
	if stringsx.Blank(tracker) {
		return torrent.OptionNoop
	}

	return torrent.OptionTrackers(tracker)
}

func RecordInfo(infopath string, dl torrent.Metadata) {
	if info := dl.InfoBytes; info != nil {
		errorsx.Log(errorsx.Wrap(os.WriteFile(infopath, info, 0600), "unable to record info file"))
	}
}
