package library

import (
	"context"
	"log"
	"strings"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
)

func KnownOptionJSONSafeEncode(t *Known) {

}

func KnownOptionTestDefaults(t *Known) {
	t.UID = errorsx.Must(uuid.NewV4()).String()
	t.Md5 = errorsx.Must(uuid.NewV4()).String()
}

func Unknown() Known {
	return Known{
		UID: uuid.Nil.String(),
	}
}
func KnownSearch(ctx context.Context, q sqlx.Queryer, b squirrel.SelectBuilder) KnownScanner {
	return NewKnownScannerStatic(b.RunWith(q).QueryContext(ctx))
}

func KnownSearchBuilder() squirrel.SelectBuilder {
	return squirrelx.PSQL.Select(sqlx.Columns(KnownScannerStaticColumns)...).From("library_known_media")
}

func DetectKnownMedia(ctx context.Context, db sqlx.Queryer, query string) (_ Known, err error) {
	// TODO: jaro similarity returns decent results if we can properly extract titles.
	type ScoredKnown struct {
		Known
		Relevance float64
	}
	var (
		result ScoredKnown = ScoredKnown{
			Known: Unknown(),
		}
	)

	log.Println("detect known media initiated", query)
	defer log.Println("detect known media completed", query)

	{
		q := KnownSearchBuilder().Where(squirrel.And{
			lucenex.Query(duckdbx.NewLucene(), query, lucenex.WithDefaultField("title")),
		})

		scanner := sqlx.Scan(KnownSearch(ctx, db, q))

		for v := range scanner.Iter() {
			var cur ScoredKnown = ScoredKnown{Known: v}

			if err := KnownScoreByID(ctx, db, v.UID, query).Scan(&cur.Relevance); err != nil {
				log.Println("unable to score", v.UID, err)
				continue
			}

			if cur.Relevance > result.Relevance {
				result = cur
				log.Println(cur.Relevance, cur.UID, cur.Title)
			}
		}

		if err := scanner.Err(); err != nil {
			return Unknown(), err
		}
	}

	if result.Relevance > 0 {
		return result.Known, nil
	}

	{
		terms := strings.ReplaceAll(query, " ", " OR ")
		q := KnownSearchBuilder().Where(squirrel.And{
			lucenex.Query(duckdbx.NewLucene(), terms, lucenex.WithDefaultField("title")),
		})

		scanner := sqlx.Scan(KnownSearch(ctx, db, q))

		for v := range scanner.Iter() {
			var cur ScoredKnown = ScoredKnown{Known: v}

			if err := KnownScoreByID(ctx, db, v.UID, query).Scan(&cur.Relevance); err != nil {
				log.Println("unable to score", v.UID, err)
				continue
			}

			if cur.Relevance > result.Relevance {
				result = cur
				log.Println(result.Relevance, result.UID, result.Title)
			}
		}

		if err := scanner.Err(); err != nil {
			return Unknown(), err
		}
	}

	return result.Known, nil
}
