package tracking

import (
	"context"
	"net/url"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/timex"
)

type RSSOption func(*RSS)

func NewFeedRSS(id string, options ...func(*RSS)) (m RSS) {
	r := langx.Clone(RSS{
		ID:          id,
		LastBuiltAt: time.UnixMicro(0), //timex.NegInf(), should be neg inf but duckdb driver data types still need work.
	}, langx.Compose(options...), RSSOptionDefaultEncryptionSeed)

	return r
}

func RSSOptionTestDefaults(p *RSS) {
	p.ID = stringsx.DefaultIfBlank(md5x.FormatUUID(md5x.Digest(p.URL)), errorsx.Must(uuid.NewV4()).String())
	p.EncryptionSeed = ""
}

// populates the encryption seed based on the url host if it hasnt already been set.
func RSSOptionDefaultEncryptionSeed(r *RSS) {
	r.EncryptionSeed = stringsx.FirstNonBlank(
		r.EncryptionSeed, md5x.FormatUUID(
			md5x.Digest(stringsx.DefaultIfBlank(
				errorsx.Zero(url.Parse(r.URL)).Host,
				uuid.Must(uuid.NewV4()).String(),
			)),
		),
	)
}

func RSSOptionDefaultFeeds(m RSS) RSSOption {
	// provides the values for default feeds
	return func(r *RSS) {
		*r = m
		r.ID = md5x.FormatUUID(md5x.Digest(m.URL))
	}
}

func RSSOptionJSONSafeEncode(p *RSS) {
	p.CreatedAt = timex.RFC3339NanoEncode(p.CreatedAt)
	p.UpdatedAt = timex.RFC3339NanoEncode(p.UpdatedAt)
	p.NextCheck = timex.RFC3339NanoEncode(p.NextCheck)
	p.LastBuiltAt = timex.RFC3339NanoEncode(p.LastBuiltAt)
}

func RSSQuerySearch(q string) squirrel.Sqlizer {
	return squirrelx.Noop{}
	// return duckdbx.FTSSearch("fts_main_torrents_feed_rss", q)
}

func RSSQueryNeedsCheck() squirrel.Sqlizer {
	return squirrel.Expr("torrents_feed_rss.next_check < NOW()")
}

func RSSSearch(ctx context.Context, q sqlx.Queryer, b squirrel.SelectBuilder) RSSScanner {
	return NewRSSScannerStatic(b.RunWith(q).QueryContext(ctx))
}

func RSSSearchBuilder() squirrel.SelectBuilder {
	return squirrelx.PSQL.Select(sqlx.Columns(RSSScannerStaticColumns)...).From("torrents_feed_rss")
}
