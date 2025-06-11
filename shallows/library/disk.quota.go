package library

import (
	"context"
	"log"
	"time"

	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

func NewDiskQuota(ctx context.Context, dir fsx.Virtual, q sqlx.Queryer) error {
	s := backoffx.New(
		backoffx.Constant(time.Hour),
		backoffx.Jitter(0.1),
	)

	for attempt, delay := range backoffx.Iter(s) {
		log.Println("disk quota initiated", attempt, delay)
		log.Println("disk quota completed", attempt, delay)
	}

	return nil
}
