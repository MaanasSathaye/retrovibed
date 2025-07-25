package cmdcommunity

type Commands struct {
	Create  cmdCommunityCreate  `cmd:"" help:"create a new community"`
	Info    cmdCommunityInfo    `cmd:"" help:"display the community details"`
	Publish cmdCommunityPublish `cmd:"" help:"create and publish a rss feed from a list of torrents"`
}
