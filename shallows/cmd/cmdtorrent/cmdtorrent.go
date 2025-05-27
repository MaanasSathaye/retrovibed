package cmdtorrent

type Commands struct {
	Import     importFilesystem `cmd:"" help:"import torrents from a file/directory"`
	Remap      remap            `cmd:"" help:"remaps symlinks to media by moving the files"`
	Magnet     cmdMagnet        `cmd:"" help:"insert magnet links for download"`
	KnownMedia cmdKnownMedia    `cmd:"" help:"best effort attempt to assign known media"`
}
