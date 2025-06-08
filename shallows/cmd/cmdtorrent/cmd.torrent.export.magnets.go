package cmdtorrent

import (
	"database/sql"
	"os"

	"github.com/Masterminds/squirrel"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/tracking"
)

type exportMagnets struct {
	Path string `arg:"" name:"path" help:"file to write magnet urls out to, defaults to stdout" default:"" required:"false"`
}

func (t exportMagnets) Run(gctx *cmdopts.Global, id *cmdopts.SSHID) (err error) {
	var (
		db *sql.DB
	)
	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQuerySeeding(),
		},
	)

	dst := os.Stdout
	if stringsx.Present(t.Path) {
		if dst, err = os.OpenFile(t.Path, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0600); err != nil {
			return err
		}
	}

	iter := sqlx.Scan(tracking.MetadataSearch(gctx.Context, db, q))

	for md := range iter.Iter() {
		md := metainfo.Magnet{
			InfoHash:    metainfo.NewHashFromBytes(md.Infohash),
			Trackers:    []string{md.Tracker},
			DisplayName: md.Description,
		}

		if _, err = dst.WriteString(md.String()); err != nil {
			return err
		}

	}

	return nil
}
