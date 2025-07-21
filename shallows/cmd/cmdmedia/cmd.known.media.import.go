package cmdmedia

import (
	"database/sql"
	"log"
	"os"

	"github.com/davecgh/go-spew/spew"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/library"
)

type knownimport struct{}

func (t knownimport) Run(gctx *cmdopts.Global) (err error) {
	var (
		db   *sql.DB
		v    library.Known
		derr error
	)

	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	d := jsonl.NewDecoder(os.Stdin)

	for derr = d.Decode(&v); derr == nil; derr = d.Decode(&v) {
		log.Println("DERP DERP", spew.Sdump(v))
		if err = library.KnownInsertWithDefaults(gctx.Context, db, v).Scan(&v); err != nil {
			return err
		}
	}
	return derr
}
