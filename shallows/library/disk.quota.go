package library

import (
	"context"
	"log"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

// Moves archivable data from disk to storage.
func NewDiskQuota(ctx context.Context, dir fsx.Virtual, q sqlx.Queryer) error {
	s := backoffx.New(
		backoffx.Constant(time.Hour),
		backoffx.Jitter(0.1),
	)

	query := MetadataSearchBuilder().Where(squirrel.And{
		MetadataQueryArchivable(),
	})
	for attempt, delay := range backoffx.Iter(s) {
		log.Println("disk quota initiated", attempt, delay)
		log.Println("disk quota completed", attempt, delay)

		v := sqlx.Scan(MetadataSearch(ctx, q, query))
		for md := range v.Iter() {
			log.Println("archivable", md.ID)
		}

		errorsx.Log(v.Err())

		select {
		case <-time.After(delay):
		case <-ctx.Done():
			return context.Cause(ctx)
		}
	}

	return nil
}
