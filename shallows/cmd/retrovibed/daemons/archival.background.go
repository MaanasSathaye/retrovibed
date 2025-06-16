package daemons

import (
	"context"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/metaapi"
)

func AutoArchival(ctx context.Context, q sqlx.Queryer, mediastore fsx.Virtual) error {
	c, err := authn.Oauth2HTTPClient(ctx)
	if err != nil {
		return errorsx.Wrap(err, "failed to create oauth2 bearer token")
	}

	if err := metaapi.Register(ctx); err != nil {
		return errorsx.Wrap(err, "unable to register with archival service")
	}

	contextx.Run(ctx, func() {
		errorsx.Log(library.NewDiskQuota(ctx, metaapi.JWTClient(c), mediastore, q))
	})

	return nil
}
