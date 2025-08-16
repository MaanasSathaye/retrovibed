package cmdmeta

import (
	"context"
	"database/sql"
	"embed"
	"io/fs"
	"log"
	"os"
	"strings"
	"sync"

	_ "github.com/marcboeker/go-duckdb/v2"

	"github.com/pressly/goose/v3"
	"github.com/retrovibed/retrovibed/internal/debugx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/goosex"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/sqlxx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/meta"
)

//go:embed .migrations/*.sql
var embedsqlite embed.FS

func Database(ctx context.Context) (db *sql.DB, err error) {
	log.Println("database path", userx.DefaultConfigDir(userx.DefaultRelRoot(), "meta.db"))

	if err := os.MkdirAll(userx.DefaultConfigDir(userx.DefaultRelRoot()), 0700); err != nil {
		return nil, err
	}

	if db, err = sql.Open("duckdb", userx.DefaultConfigDir(userx.DefaultRelRoot(), "meta.db")); err != nil {
		return nil, errorsx.Wrap(err, "unable to open db")
	}
	defer func() {
		if err == nil {
			return
		}
		debugx.Println("closing database due to error during initialization", err)
		errorsx.Log(db.Close())
	}()

	return db, InitializeDatabase(ctx, db)
}

var m sync.Mutex

func InitializeDatabase(ctx context.Context, db *sql.DB) (err error) {
	m.Lock()
	defer m.Unlock()

	mprov, err := goose.NewProvider("", db, errorsx.Must(fs.Sub(embedsqlite, ".migrations")), goose.WithStore(goosex.DuckdbStore{}))
	if err != nil {
		return errorsx.Wrap(err, "unable to build migration provider")
	}

	if _, err := mprov.Up(ctx); err != nil {
		return errorsx.Wrap(err, "unable to run migrations")
	}

	return nil
}

func Checkpoint(ctx context.Context, db *sql.DB) (err error) {
	log.Println("------------------------------------------------ database checkpoint initiated ------------------------------------------------")
	defer log.Println("------------------------------------------------ database checkpoint completed ------------------------------------------------")

	if _, err := db.ExecContext(ctx, "PRAGMA create_fts_index('library_metadata', 'id', 'description', overwrite = 1);"); err != nil {
		return errorsx.Wrap(err, "failed to refresh library_metadata fts index")
	}

	if _, err := db.ExecContext(ctx, "PRAGMA create_fts_index('torrents_metadata', 'id', 'description', overwrite = 1);"); err != nil {
		return errorsx.Wrap(err, "failed to refresh torrents_metadata fts index")
	}

	if _, err := db.ExecContext(ctx, "PRAGMA create_fts_index('library_known_media', 'md5_lower', 'title', overwrite = 1);"); err != nil {
		return errorsx.Wrap(err, "failed to refresh library_known_media fts index")
	}

	if _, err := db.ExecContext(ctx, "CHECKPOINT;"); err != nil {
		return errorsx.Wrap(err, "failed to checkpoint database")
	}

	return nil
}

func Hostnames(ctx context.Context, q sqlx.Queryer) ([]string, error) {
	var (
		results []meta.Daemon
	)

	if err := sqlxx.ScanInto(meta.DaemonSearch(ctx, q, meta.DaemonSearchBuilder().Limit(128)), &results); err != nil {
		return nil, errorsx.Wrap(err, "unable to retrieve hostnames")
	}

	return slicesx.MapTransform(func(d meta.Daemon) string {
		before, _, _ := strings.Cut(d.Hostname, ":")
		return before
	}, results...), nil
}
