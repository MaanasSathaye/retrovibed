package torrentx

import (
	"context"
	"errors"
	"fmt"
	"iter"
	"log"
	"net"
	"net/netip"
	"os"
	"time"

	"github.com/james-lawrence/torrent"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/natpmp"
	"github.com/retrovibed/retrovibed/internal/netx"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/wireguardx"

	"github.com/anacrolix/utp"
	"github.com/james-lawrence/torrent/dht"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/dht/krpc"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/sockets"
	"github.com/james-lawrence/torrent/tracker"

	"golang.zx2c4.com/wireguard/conn"
	"golang.zx2c4.com/wireguard/device"
	"golang.zx2c4.com/wireguard/tun/netstack"
)

func AnnouncerFromClient(c *torrent.Client) tracker.Announce {
	return c.Config().AnnounceRequest()
}

func localsocket(port uint16) (s0 *utp.Socket, s1 net.Listener, err error) {
	if s0, err = utp.NewSocket("udp", fmt.Sprintf(":%d", port)); err != nil {
		return nil, nil, errorsx.Wrap(err, "unable to open utp socket")
	}

	if addr, ok := s0.Addr().(*net.UDPAddr); ok {
		if s1, err = net.Listen("tcp", fmt.Sprintf(":%d", addr.Port)); err != nil {
			s0.Close()
			return nil, nil, errorsx.Wrap(err, "unable to open tcp socket")
		}
	}

	return s0, s1, nil
}

func Autosocket(p uint16) (_ torrent.Binder, err error) {
	var (
		s1 *utp.Socket
		s2 net.Listener
	)

	if s1, s2, err = localsocket(p); err != nil {
		return nil, err
	}

	return torrent.NewSocketsBind(sockets.New(s1, s1), sockets.New(s2, &net.Dialer{})).Options(torrent.BinderOptionDHT), nil
}

func WireguardSocket(wcfg *wireguardx.Config, port uint16) (_ *netstack.Net, _ torrent.Binder, err error) {
	var (
		s0, s1    sockets.Socket
		utpsocket *utp.Socket
		// logger    = device.NewLogger(device.LogLevelError, "")
		logger = device.NewLogger(device.LogLevelVerbose, "")
	)

	if port == 0 {
		panic("wireguard sockets requires a specified torrent port")
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

	conn, err := tnet.ListenUDP(&net.UDPAddr{Port: int(port)})
	if err != nil {
		return nil, nil, errorsx.Wrap(err, "failed to listen on port")
	}

	if utpsocket, err = utp.NewSocketFromPacketConn(conn); err != nil {
		return nil, nil, errorsx.Wrap(err, "failed to create utp socket")
	}

	s0 = sockets.New(utpsocket, utpsocket)
	if addr, ok := utpsocket.Addr().(*net.UDPAddr); ok {
		s, err := tnet.ListenTCP(&net.TCPAddr{Port: addr.Port})
		if err != nil {
			return nil, nil, errorsx.Wrap(err, "unable to open tcp socket")
		}
		s1 = sockets.New(s, tnet)
	}

	return tnet, torrent.NewSocketsBind(s0, s1).Options(torrent.BinderOptionDHT), nil
}

func ExternalPort(wcfg *wireguardx.Config, d netx.Dialer, port uint16) (_zero netip.AddrPort, _ time.Duration, err error) {
	dnsgateway := slicesx.FirstOrZero(wcfg.Interface.DNS...)

	client := natpmp.NewClient(dnsgateway, natpmp.OptionTimeout(15*time.Second), natpmp.OptionDialer(d))

	ex, err := client.GetExternalAddress()
	if err != nil {
		return _zero, 0, errorsx.Wrapf(err, "unable to determine external ip: %s", dnsgateway)
	}

	result, err := client.AddPortMapping("tcp", int(port), int(port), int(time.Hour/time.Second))
	if err != nil {
		return _zero, 0, errorsx.Wrapf(err, "unable to map port: %s", dnsgateway)
	}

	return netip.AddrPortFrom(netip.AddrFrom4(ex.ExternalIPAddress), result.MappedExternalPort), time.Duration(result.PortMappingLifetimeInSeconds) * time.Second, nil
}

func DynamicIP(wcfg *wireguardx.Config, d netx.Dialer, port uint16) torrent.ClientConfigOption {
	return torrent.ClientConfigDynamicIP(func(ctx context.Context, c *torrent.Client) (iter.Seq[netip.AddrPort], error) {
		return func(yield func(netip.AddrPort) bool) {
			for {
				addr, d, err := ExternalPort(wcfg, d, port)
				if err != nil {
					log.Println("failed to map ports", err)
					time.Sleep(time.Minute)
					continue
				}

				if !yield(addr) {
					// log.Println("unable to yield address")
					panic("unable to yield address")
				}

				time.Sleep(d)
			}
		}, nil
	})
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
		if minfo.ID().Cmp(int160.New([]byte(minfo.InfoBytes))) == 0 {
			return torrent.OptionInfo(minfo.InfoBytes)
		}

		panic("tisk tisk")
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
