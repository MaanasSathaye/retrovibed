package tracking

import (
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/internal/md5x"
)

func HashUID(md *metainfo.Hash) string {
	return md5x.FormatUUID(md5x.Digest(md.Bytes()))
}

func PublicTrackers() []string {
	return []string{
		"udp://tracker.opentrackr.org:1337/announce",
		"udp://open.demonii.com:1337/announce",
		"udp://open.stealth.si:80/announce",
		"udp://explodie.org:6969/announce",
		"udp://tracker.torrent.eu.org:451/announce",
		"udp://exodus.desync.com:6969/announce",
		"udp://retracker01-msk-virt.corbina.net:80/announce",
		"udp://leet-tracker.moe:1337/announce",
		"udp://isk.richardsw.club:6969/announce",
		"udp://bt.ktrackers.com:6666/announce",
		"http://www.genesis-sp.org:2710/announce",
		"http://tracker.xiaoduola.xyz:6969/announce",
		"http://tracker.vanitycore.co:6969/announce",
		"http://tracker.sbsub.com:2710/announce",
		"http://tracker.moxing.party:6969/announce",
		"http://tracker.dmcomic.org:2710/announce",
		"http://tracker.bt-hash.com:80/announce",
		"http://t.jaekr.sh:6969/announce",
		"http://shubt.net:2710/announce",
		"http://share.hkg-fansub.info:80/announce.php",
		"udp://93.158.213.92:1337/announce",
		"udp://23.140.248.9:1337/announce",
		"udp://185.243.218.213:80/announce",
		"udp://91.216.110.53:451/announce",
		"udp://23.157.120.14:6969/announce",
		"udp://208.83.20.20:6969/announce",
		"udp://83.31.191.39:6969/announce",
		"udp://54.39.48.3:6969/announce",
		"udp://211.75.210.220:80/announce",
		"udp://135.125.202.143:6969/announce",
		"udp://144.126.245.19:6969/announce",
		"udp://176.56.6.77:6969/announce",
		"udp://89.110.76.229:6969/announce",
		"udp://45.154.96.35:6969/announce",
		"udp://209.141.59.25:6969/announce",
		"udp://108.53.194.223:6969/announce",
		"udp://5.255.124.190:6969/announce",
		"udp://52.58.128.163:6969/announce",
		"udp://34.94.76.146:6969/announce",
	}
}
