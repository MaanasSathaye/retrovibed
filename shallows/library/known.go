package library

import (
	"context"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
)

func KnownOptionJSONSafeEncode(t *Known) {

}

func KnownOptionTestDefaults(t *Known) {
	t.UID = errorsx.Must(uuid.NewV4()).String()
	t.Md5 = errorsx.Must(uuid.NewV4()).String()
	t.Adult = false
}

func Unknown() Known {
	return Known{
		UID: uuid.Nil.String(),
	}
}
func KnownSearch(ctx context.Context, q sqlx.Queryer, b squirrel.SelectBuilder) KnownScanner {
	return NewKnownScannerStatic(b.RunWith(q).QueryContext(ctx))
}

func KnownQueryExplicit(b bool) squirrel.Sqlizer {
	return squirrel.Expr("library_known_media.adult = ?", b)
}

func KnownQuerySimilarity(q string, cutoff float32) squirrel.Sqlizer {
	return squirrel.Expr("((jaro_winkler_similarity(library_known_media.title, ?, ?) + jaro_similarity(library_known_media.title, ?, ?)) / 2) > 0.5", q, cutoff, q, cutoff)
}

func KnownSearchBuilder() squirrel.SelectBuilder {
	return squirrelx.PSQL.Select(sqlx.Columns(KnownScannerStaticColumns)...).From("library_known_media")
}

func DetectKnownMedia(ctx context.Context, db sqlx.Queryer, query string) (k Known, err error) {
	k = Unknown()

	if err := KnownBestMatch(ctx, db, query, 0.7).Scan(&k); sqlx.IgnoreNoRows(err) != nil {
		return k, errorsx.Wrap(err, "unable to score")
	}

	return k, nil
}
