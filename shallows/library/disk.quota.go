package library

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/shirou/gopsutil/v4/disk"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

// Moves archivable data from disk to storage.
func NewDiskQuota(ctx context.Context, c *http.Client, dir fsx.Virtual, q sqlx.Queryer) error {
	s := backoffx.New(
		backoffx.Constant(time.Hour),
		backoffx.Jitter(0.1),
	)

	query := MetadataSearchBuilder().Where(squirrel.And{
		MetadataQueryArchivable(),
	})

	archive := func(attempt int, delay time.Duration) error {
		log.Println("disk quota initiated", attempt, delay)
		defer log.Println("disk quota completed", attempt, delay)

		a := deeppool.NewArchiver(c)

		v := sqlx.Scan(MetadataSearch(ctx, q, query))
		for md := range v.Iter() {
			log.Println("archivable", md.ID)

			if err := Archive(ctx, q, md, dir, a); err != nil {
				errorsx.Log(errorsx.Wrapf(err, "archival upload failed: %s", md.ID))
				continue
			}

			// bcache, err := blockcache.NewDirectoryCache(dir.Path(md.ID))
			// if err != nil {
			// 	errorsx.Log(errorsx.Wrapf(err, "unable to create reader: %s", md.ID))
			// 	continue
			// }

			// uploaded, err := a.Upload(ctx, md.Mimetype, io.NewSectionReader(bcache, int64(md.DiskOffset), int64(md.Bytes)))
			// if err != nil {
			// 	errorsx.Log(errorsx.Wrapf(err, "archival upload failed: %s", md.ID))
			// 	continue
			// }

			// log.Println("uploaded", spew.Sdump(uploaded))
			// if err := MetadataArchivedByID(ctx, q, md.ID, uploaded.Id, uploaded.Usage).Scan(&md); err != nil {
			// 	errorsx.Log(errorsx.Wrapf(err, "update for metadata failed: %s", md.ID))
			// 	continue
			// }
		}

		if err := v.Err(); err != nil {
			return err
		}

		select {
		case <-time.After(delay):
		case <-ctx.Done():
			return context.Cause(ctx)
		}

		return nil
	}

	for attempt, delay := range backoffx.Iter(s) {
		if usage, err := disk.UsageWithContext(ctx, dir.Path()); err != nil {
			log.Println(errorsx.Wrap(err, "unable to retrieve disk"))
		} else {
			log.Println("usage", dir.Path(), usage.UsedPercent, usage.Fstype)
		}

		errorsx.Log(archive(attempt, delay))
	}

	return nil
}
