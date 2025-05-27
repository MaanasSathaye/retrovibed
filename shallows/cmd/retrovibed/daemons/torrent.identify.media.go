package daemons

import (
	"context"
	"log"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

func IdentifyTorrentyMedia(ctx context.Context, db sqlx.Queryer) error {
	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQueryNeedsKnownMediaID(),
		},
	)

	iter := sqlx.Scan(tracking.MetadataSearch(ctx, db, q))

	for md := range iter.Iter() {
		var (
			err   error
			known *library.Known
		)

		if known, err = library.DetectKnownMedia(ctx, db, md.Description); err != nil {
			log.Println("unable to detect media for torrent", md.ID, err)
			continue
		}

		if err = tracking.MetadataAssignKnownMediaID(ctx, db, md.ID, known.UID).Scan(&md); err != nil {
			log.Println("unable to assign known media id to torrent", md.ID, known.UID, err)
			continue
		}
	}

	return errorsx.Wrap(iter.Err(), "failed to mark known media torrents")
}
