package cmdmedia

import (
	"database/sql"
	"os"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/sqlxx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

type reindex struct {
	Unindexed bool `flag:"" name:"unindexed" help:"only run against records that havent been indexed" default:"false"`
}

func (t reindex) Run(gctx *cmdopts.Global) (err error) {

	var (
		db      *sql.DB
		missing squirrel.Sqlizer = squirrelx.Noop{}
	)

	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	mediastore := fsx.DirVirtual(env.MediaDir())

	if t.Unindexed {
		missing = library.MetadataQueryNotIndexed()
	}

	query := library.MetadataSearchBuilder().Where(
		squirrel.And{
			squirrel.Expr("'t' = 't'"),
			missing,
		},
	)

	return sqlxx.ScanEach(library.MetadataSearch(gctx.Context, db, query), func(md *library.Metadata) error {
		if md.TorrentID != uuid.Nil.String() {
			// JAL 2025-05-24: this if statement can be removed once v0 is out.
			var tmd tracking.Metadata

			if err = tracking.MetadataFindByID(gctx.Context, db, md.TorrentID).Scan(&tmd); sqlx.ErrNoRows(err) != nil {
				return nil
			} else if err != nil {
				return err
			}

			resolved, err := os.Readlink(mediastore.Path(md.ID))
			if err != nil {
				return nil
			}

			if err = library.MetadataUpdateDescriptionByID(gctx.Context, db, md.ID, tracking.DescriptionFromPath(&tmd, tracking.DescriptionFromPath(&tmd, resolved))).Scan(md); err != nil {
				return err
			}
		}

		if err = library.MetadataUpdateAutodescriptionByID(gctx.Context, db, md.ID, tracking.NormalizedDescription(md.Description)).Scan(md); err != nil {
			return err
		}
		return nil
	})
}
