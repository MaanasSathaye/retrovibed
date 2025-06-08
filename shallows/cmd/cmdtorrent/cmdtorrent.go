package cmdtorrent

type Commands struct {
	Import     importFilesystem `cmd:"" help:"import torrents from a file/directory"`
	ImportPeer importPeer       `cmd:"" help:"import torrents from a specific peer and a list of magnet urls"`
	Export     exportMagnets    `cmd:"" help:"export seeded torrents as megnet urls to a file"`
	Remap      remap            `cmd:"" help:"remaps symlinks to media by moving the files"`
	Magnet     cmdMagnet        `cmd:"" help:"insert magnet links for download"`
	KnownMedia cmdKnownMedia    `cmd:"" help:"best effort attempt to assign known media"`
}
