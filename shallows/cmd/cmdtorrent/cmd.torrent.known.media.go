package cmdtorrent

import (
	"database/sql"
	"log"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

type cmdKnownMedia struct{}

func (t cmdKnownMedia) Run(ctx *cmdopts.Global) (err error) {
	var (
		db *sql.DB
	)

	if db, err = cmdmeta.Database(ctx.Context); err != nil {
		return err
	}
	defer db.Close()

	q := tracking.MetadataSearchBuilder().Where(squirrel.And{
		tracking.MetadataQueryNeedsKnownMediaID(),
	})

	iter := sqlx.Scan(tracking.MetadataSearch(ctx.Context, db, q))
	for md := range iter.Iter() {
		var (
			known library.Known
		)

		if known, err = library.DetectKnownMedia(ctx.Context, db, lucenex.Clean(md.Description)); err != nil {
			log.Println("failed to detect known media", err)
			continue
		}

		if err = tracking.MetadataAssignKnownMediaID(ctx.Context, db, md.ID, known.UID).Scan(&md); err != nil {
			log.Println("failed to assign known media", md.ID, known.UID)
		}
	}

	return err
}
