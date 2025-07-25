package cmdmedia

type Commands struct {
	Import  importFilesystem `cmd:"" help:"import files and directories"`
	Export  exportFilesystem `cmd:"" help:"export media to a directory"`
	Reindex reindex          `cmd:"" help:"run the indexing process on media contents, this can take a bit"`
	Known   Known            `cmd:"" help:"functionality for managing known media"`
}

type Known struct {
	TMDB    tmdbimport   `cmd:"" help:"import known media from tmdb and writes them to stdout in known media jsonl format for importing"`
	Query   knownquery   `cmd:"" help:"run a query against known media"`
	Import  knownimport  `cmd:"" help:"processes a file or stdin to import media metadata records directly into the database"`
	Archive knownarchive `cmd:"" help:"processes stdin and creates a directory of files of media metadata"`
}
