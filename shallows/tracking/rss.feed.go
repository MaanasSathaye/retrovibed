package tracking

import (
	"context"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
	"github.com/retrovibed/retrovibed/internal/timex"
)

func NewFeedRSS(id string, options ...func(*RSS)) (m RSS) {
	r := langx.Clone(RSS{
		ID:          id,
		LastBuiltAt: time.UnixMicro(0), //timex.NegInf(), should be neg inf but duckdb driver data types still need work.
	}, options...)
	return r
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
