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
	donecond := sync.NewCond(&sync.Mutex{})
	a := &AsyncWakeup{
		Cond:     sync.NewCond(&sync.Mutex{}),
		doneCond: donecond,
		C:        q,
		cleanup: sync.OnceFunc(func() {
			log.Println("async wakeup shutdown initiated")
			done()
			select {
			case q <- errAsyncClosed:
				log.Println("async wakeup sent closed error")
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
		<-ictx.Done()
		a.Broadcast()
	}()

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

// Moves archivable data from disk to storage.
func NewDiskQuota(ctx context.Context, c *http.Client, dir fsx.Virtual, q sqlx.Queryer, async *AsyncWakeup, reclaimdisk bool) error {
	query := MetadataSearchBuilder().Where(squirrel.And{
		MetadataQueryArchivable(),
	})

	archive := func() error {
		if usage, err := disk.UsageWithContext(ctx, dir.Path()); err != nil {
			log.Println(errorsx.Wrap(err, "unable to retrieve disk"))
		} else {
			log.Println("usage", dir.Path(), usage.UsedPercent, usage.Fstype)
		}

		log.Println("disk quota initiated")
		defer log.Println("disk quota completed")

		a := deeppool.NewArchiver(c)

		v := sqlx.Scan(MetadataSearch(ctx, q, query))
		for md := range v.Iter() {
			log.Println("------------------------- archivable initiated", md.ID)
			if err := Archive(ctx, q, md, dir, a); err != nil {
				errorsx.Log(errorsx.Wrapf(err, "archival upload failed: %s", md.ID))
				continue
			}

			// if reclaimdisk {
			// 	if err := Reclaim(ctx, md, dir); err != nil {
			// 		errorsx.Log(errorsx.Wrapf(err, "disk reclaimation failed: %s", md.ID))
			// 		continue
			// 	}
			// }
			log.Println("------------------------- archivable completed", md.ID)
		}

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

	if err := untilClosed(); errorsx.Is(err, context.Canceled, context.DeadlineExceeded) {
		log.Println("archival completed", err)
		return nil
	} else if errorsx.Is(err, errAsyncClosed) {
		// signal everything is done so the close function returns
		defer async.doneCond.Broadcast()
		// run a final time to ensure everything is archived.
		return errorsx.Ignore(archive(), context.Canceled, context.DeadlineExceeded)
	} else {
		return errorsx.Wrap(err, "archival failed")
	}
}
