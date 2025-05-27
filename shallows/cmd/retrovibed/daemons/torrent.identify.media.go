package daemons

import (
	"context"
	"log"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

func IdentifyTorrentyMedia(ctx context.Context, db sqlx.Queryer) error {
	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQueryNeedsKnownMediaID(),
		},
	).Limit(1024)

	iter := sqlx.Scan(tracking.MetadataSearch(ctx, db, q))

	for md := range iter.Iter() {
		var (
			err   error
			known library.Known
		)

		if known, err = library.DetectKnownMedia(ctx, db, lucenex.Clean(md.Description)); err != nil {
			log.Println("unable to detect media for torrent", md.ID, md.Description, "|", lucenex.Clean(md.Description), "|", err)
			continue
		}

		log.Println("matched", md.ID, "with", known.UID, known.Title)
		if err = tracking.MetadataAssignKnownMediaID(ctx, db, md.ID, known.UID).Scan(&md); err != nil {
			log.Println("unable to assign known media id to torrent", md.ID, known.UID, err)
			continue
		}

		log.Println("assigned known media", md.ID, known.UID)
	}

	return errorsx.Wrap(iter.Err(), "failed to mark known media torrents")
}
