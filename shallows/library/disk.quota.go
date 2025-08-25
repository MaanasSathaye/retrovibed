package library

import (
	"context"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/shirou/gopsutil/v4/disk"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

const errAsyncClosed = errorsx.String("async archive closed")

type AsyncWakeup struct {
	*sync.Cond
	doneCond *sync.Cond
	C        <-chan error
	cleanup  func()
}

func (t *AsyncWakeup) Close() error {
	t.cleanup()
	return nil
}

func NewAsyncWakeup(ctx context.Context) *AsyncWakeup {
	ictx, done := context.WithCancel(ctx)
	q := make(chan error, 1)
	wakeup := sync.NewCond(&sync.Mutex{})
	donecond := sync.NewCond(&sync.Mutex{})
	a := &AsyncWakeup{
		Cond:     wakeup,
		doneCond: donecond,
		C:        q,
		cleanup: sync.OnceFunc(func() {
			log.Println("async wakeup shutdown initiated")
			done()
			select {
			case q <- errAsyncClosed:
				log.Println("async wakeup sent closed error")
				wakeup.Broadcast()
			case <-ctx.Done():
				log.Println("async wakeup parent context was cancelled")
			}
			donecond.L.Lock()
			donecond.Wait()
			donecond.L.Unlock()
			close(q)
		}),
	}

	go func() {
		for {
			a.L.Lock()
			a.Wait()
			a.L.Unlock()

			select {
			case <-ictx.Done():
				return
			case q <- nil:
			default:
			}
		}
	}()
	return a
}

func PeriodicWakeup(ctx context.Context, async *AsyncWakeup, b backoffx.Strategy) {
	for _, delay := range backoffx.Iter(b) {
		async.Broadcast()
		log.Println("periodic disk quota initiated next", delay)
		time.Sleep(delay)
	}
}

// Moves archivable data from disk to cloud storage.
func NewAutoArchive(ctx context.Context, c *http.Client, dir fsx.Virtual, q sqlx.Queryer, async *AsyncWakeup, archivedisk bool) error {
	query := MetadataSearchBuilder().Where(squirrel.And{
		MetadataQueryArchivable(),
	})

	archive := func() error {
		var processed uint64
		log.Println("archival initiated")
		defer log.Println("archival completed")

		a := deeppool.NewArchiver(c)

		v := sqlx.Scan(MetadataSearch(ctx, q, query))
		for md := range v.Iter() {
			processed++
			log.Println("------------------------- archivable initiated", md.ID, md.ArchiveID)

			if archivedisk {
				if err := Archive(ctx, q, md, dir, a); err != nil {
					errorsx.Log(errorsx.Wrapf(err, "archival upload failed: %s", md.ID))
					continue
				}
			} else {
				log.Println("dry-run - not archiving", md.ID)
			}

			log.Println("------------------------- archivable completed", md.ID)
		}

		log.Println("archival processed", processed, "records")
		return v.Err()
	}

	untilClosed := func() error {
		for {
			if err := archive(); err != nil {
				return err
			}

			select {
			case err := <-async.C:
				if err != nil {
					return err
				}
			case <-ctx.Done():
				return context.Cause(ctx)
			}
		}
	}

	// signal everything is done so the close function returns
	defer async.doneCond.Broadcast()
	if err := untilClosed(); errorsx.Is(err, context.Canceled, context.DeadlineExceeded) {
		return nil
	} else if errorsx.Is(err, errAsyncClosed) {
		// run a final time to ensure everything is archived.
		return errorsx.Ignore(archive(), context.Canceled, context.DeadlineExceeded)
	} else {
		return errorsx.Wrap(err, "archival failed")
	}
}

// Clears archived data from disk.
func NewDiskReclaim(ctx context.Context, dir fsx.Virtual, q sqlx.Queryer, async *AsyncWakeup, reclaimdisk bool) error {
	query := MetadataSearchBuilder().Where(squirrel.And{
		MetadataQueryArchived(),
	}).OrderBy("library_metadata.bytes DESC")

	reclaim := func() error {
		var processed uint64
		log.Println("disk reclaim initiated")
		defer log.Println("disk reclaim completed")

		v := sqlx.Scan(MetadataSearch(ctx, q, query))
		for md := range v.Iter() {
			if !fsx.Exists(dir.Path(md.ID)) {
				continue
			}

			if usage, err := disk.UsageWithContext(ctx, dir.Path()); err != nil {
				log.Println(errorsx.Wrap(err, "unable to retrieve disk"))
				continue
			} else if usage.UsedPercent <= 80 {
				// dont continue if disk space remains below 80%
				return v.Err()
			} else {
				log.Println("usage reclaiming", dir.Path(), usage.UsedPercent, usage.Fstype, md.ID, md.ArchiveID)
			}

			log.Println("------------------------- reclaim initiated", md.ID, md.ArchiveID)
			if reclaimdisk {
				if err := Reclaim(ctx, md, dir); err != nil {
					errorsx.Log(errorsx.Wrapf(err, "disk reclaimation failed: %s", md.ID))
					continue
				}
			} else {
				log.Println("dry-run - not reclaim", md.ID)
			}

			log.Println("------------------------- reclaim completed", md.ID, md.Bytes, md.DiskUsage)
		}

		log.Println("reclaim processed", processed, "records")
		return v.Err()
	}

	untilClosed := func() error {
		for {
			if err := reclaim(); err != nil {
				return err
			}

			select {
			case err := <-async.C:
				if err != nil {
					return err
				}
			case <-ctx.Done():
				return context.Cause(ctx)
			}
		}
	}

	// signal everything is done so the close function returns
	defer async.doneCond.Broadcast()
	if err := untilClosed(); errorsx.Is(err, context.Canceled, context.DeadlineExceeded) {
		return nil
	} else if errorsx.Is(err, errAsyncClosed) {
		// run a final time to ensure everything is archived.
		return errorsx.Ignore(reclaim(), context.Canceled, context.DeadlineExceeded)
	} else {
		return errorsx.Wrap(err, "reclaim failed")
	}
}
