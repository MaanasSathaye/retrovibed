package cmdmedia

type Commands struct {
	Import  importFilesystem `cmd:"" help:"import files and directories"`
	Export  exportFilesystem `cmd:"" help:"export media to a directory"`
	Reindex reindex          `cmd:"" help:"run the indexing process on media contents, this can take a bit"`
}
