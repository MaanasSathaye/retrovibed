package cmdmedia

type Commands struct {
	Import     importFilesystem `cmd:"" help:"import files and directories"`
	Export     exportFilesystem `cmd:"" help:"export media to a directory"`
	Reindex    reindex          `cmd:"" help:"run the indexing process on media contents, this can take a bit"`
	Known      knownimport      `cmd:"" help:"run the known media import mechanism"`
	KnownQuery knownquery       `cmd:"" help:"run a query against known media"`
}
