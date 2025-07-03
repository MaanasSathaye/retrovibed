package daemons

import (
	"context"
	"time"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/metaapi"
)

func AutoArchival(ctx context.Context, q sqlx.Queryer, mediastore fsx.Virtual, async *library.AsyncWakeup, reclaimdisk bool) error {
	c, err := authn.Oauth2HTTPClient(ctx)
	if err != nil {
		return errorsx.Wrap(err, "failed to create oauth2 bearer token")
	}

	s := backoffx.New(
		backoffx.Constant(time.Hour),
		backoffx.Jitter(0.1),
	)

	go library.PeriodicWakeup(ctx, async, s)
	contextx.Run(ctx, func() {
		errorsx.Log(library.NewDiskQuota(ctx, metaapi.JWTClient(c), mediastore, q, async, reclaimdisk))
	})

	return nil
}
