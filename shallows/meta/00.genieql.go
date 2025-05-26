//go:build genieql.generate
// +build genieql.generate

package meta

import (
	"context"

	genieql "github.com/james-lawrence/genieql/ginterp"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

func Profile(gql genieql.Structure) {
	gql.From(
		gql.Table("meta_profiles"),
	)
}

func ProfileScanner(gql genieql.Scanner, pattern func(i Profile)) {
	gql.ColumnNamePrefix("meta_profiles.")
}

func ProfileInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Profile) NewProfileScannerStaticRow,
) {
	gql.Into("meta_profiles").Default("id", "session_watermark", "created_at", "updated_at", "disabled_at", "disabled_manually_at", "disabled_pending_approval_at").Conflict("ON CONFLICT (id) DO UPDATE SET updated_at = DEFAULT")
}

func ProfileInsertWithID(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Profile) NewProfileScannerStaticRow,
) {
	gql.Into("meta_profiles").Default("session_watermark", "created_at", "updated_at", "disabled_at", "disabled_manually_at", "disabled_pending_approval_at").Conflict("ON CONFLICT (id) DO UPDATE SET updated_at = DEFAULT")
}

func ProfileFindByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewProfileScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + ProfileScannerStaticColumns + ` FROM meta_profiles WHERE "id" = {id}`)
}

func Daemon(gql genieql.Structure) {
	gql.From(
		gql.Table("meta_daemons"),
	)
}

func DaemonScanner(gql genieql.Scanner, pattern func(i Daemon)) {
	gql.ColumnNamePrefix("meta_daemons.")
}

func DaemonInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Daemon) NewDaemonScannerStaticRow,
) {
	gql.Into("meta_daemons").Default("created_at", "updated_at").Conflict("ON CONFLICT (id) DO UPDATE SET updated_at = DEFAULT")
}

func DaemonFindByLatestUpdated(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer) NewDaemonScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + DaemonScannerStaticColumns + ` FROM meta_daemons ORDER BY updated_at DESC LIMIT 1`)
}

func DaemonTouch(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewDaemonScannerStaticRow,
) {
	gql = gql.Query(`UPDATE meta_daemons SET updated_at = NOW() WHERE "id" = {id} RETURNING ` + DaemonScannerStaticColumns)
}

// requires partial indexes to support this.
// func DaemonTouch2(
// 	gql genieql.Function,
// 	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewDaemonScannerStaticRow,
// ) {
// 	copy := strings.ReplaceAll(DaemonScannerStaticColumns, "meta_daemons.\"id\",", "'ffffffff-ffff-ffff-ffff-ffffffffffff',")
// 	gql = gql.Query(`BEGIN; DELETE FROM meta_daemons WHERE id = 'ffffffff-ffff-ffff-ffff-ffffffffffff'; INSERT INTO meta_daemons (` + DaemonScannerStaticColumns + `) SELECT ` + copy + ` FROM meta_daemons WHERE "id" = {id} RETURNING ` + DaemonScannerStaticColumns + `; COMMIT`)
// }

func DaemonDeleteByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewDaemonScannerStaticRow,
) {
	gql = gql.Query(`DELETE FROM meta_daemons WHERE "id" = {id} RETURNING ` + DaemonScannerStaticColumns)
}

func ConsumedToken(gql genieql.Structure) {
	gql.From(
		gql.Table("meta_consumed_tokens"),
	)
}

func ConsumedTokenScanner(gql genieql.Scanner, pattern func(a ConsumedToken)) {
	gql.ColumnNamePrefix("meta_consumed_tokens.")
}

func ConsumedTokenFindBy(gql genieql.QueryAutogen, ctx context.Context, q sqlx.Queryer, e ConsumedToken) NewConsumedTokenScannerStaticRow {
	gql.From("meta_consumed_tokens")
}

func ConsumedTokenInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a ConsumedToken) NewConsumedTokenScannerStaticRow,
) {
	gql.Into("meta_consumed_tokens").Default("created_at")
}

func Authz(gql genieql.Structure) {
	gql.From(
		gql.Table("authz_meta"),
	)
}

func AuthzScanner(gql genieql.Scanner, pattern func(a Authz)) {
	gql.ColumnNamePrefix("authz_meta.")
}

func AuthzFindBy(gql genieql.QueryAutogen, ctx context.Context, q sqlx.Queryer, e Authz) NewAuthzScannerStaticRow {
	gql.From("authz_meta")
}

func AuthzInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Authz) NewAuthzScannerStaticRow,
) {
	gql.Into("authz_meta").Default("id", "created_at")
}

func AuthzInsertWithIDDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Authz) NewAuthzScannerStaticRow,
) {
	gql.Into("authz_meta").Default("created_at").Conflict("ON CONFLICT (id) DO UPDATE SET updated_at = DEFAULT")
}

// upsert a single record with default fields.
func AuthzUpsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, p Authz) NewAuthzScannerStaticRow,
) {
	gql.Into("authz_meta").
		Default("id", "created_at", "updated_at").
		Conflict("ON CONFLICT (profile_id) DO UPDATE SET usermanagement = EXCLUDED.usermanagement, updated_at = DEFAULT")
}

func AuthzDeleteByProfileID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewAuthzScannerStaticRow,
) {
	gql = gql.Query(`DELETE FROM authz_meta WHERE profile_id = {id} RETURNING ` + AuthzScannerStaticColumns)
}
