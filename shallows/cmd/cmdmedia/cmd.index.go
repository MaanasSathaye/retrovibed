package cmdmedia

import (
	"database/sql"
	"log"
	"path/filepath"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
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
		log.Println("reindexing", md.ID)
		log.Println("path", errorsx.Zero(filepath.EvalSymlinks(mediastore.Path(md.ID))))
		if err = library.MetadataUpdateAutodescriptionByID(gctx.Context, db, md.ID, tracking.NormalizedDescription(md.Description)).Scan(md); err != nil {
			return err
		}

		if err = library.MetadataUpdateDescriptionByID(gctx.Context, db, md.ID, tracking.DescriptionFromPath(&tracking.Metadata{ID: md.TorrentID}, errorsx.Zero(filepath.EvalSymlinks(mediastore.Path(md.ID))))).Scan(md); err != nil {
			return err
		}

		return nil
	})
}
