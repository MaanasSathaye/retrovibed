package cmdmedia

import (
	"database/sql"
	"log"
	"strings"

	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

type knownimport struct {
	Source string `flag:"" name:"source" help:"4 character source id" default:"tmdb"`
	URL    string `flag:"" name:"baseurl" help:"url base for image assets" default:"https://image.tmdb.org/t/p/original/"`
	Path   string `arg:"" name:"path" help:"csv file to import" required:"true"`
}

func (t knownimport) Run(gctx *cmdopts.Global) (err error) {
	const (
		template = `INSERT INTO library_known_media (
      uid,
      md5,
      md5_lower,
      id,
      title,
      vote_average,
      vote_count,
      status,
      release_date,
      revenue,
      runtime,
      adult,
      backdrop_path,
      budget,
      homepage,
      imdb_id,
      original_language,
      original_title,
      overview,
      popularity,
      poster_path,
      tagline,
      genres,
      production_companies,
      production_countries,
      spoken_languages,
      keywords
) SELECT
      CAST(TO_HEX($1) || '-0000-0000-0000-' || LPAD(TO_HEX(COALESCE(csv.id, 0)), 12, '0') AS UUID) AS uid,
      MD5(TO_JSON(csv)),
      md5_number_lower(TO_JSON(csv)),
      COALESCE(csv.id, 0),
      COALESCE(csv.title, ''),
      COALESCE(csv.vote_average, 0.0),
      COALESCE(csv.vote_count, 0),
      COALESCE(csv.status, ''),
      COALESCE(csv.release_date, 'infinity'::DATE),
      COALESCE(csv.revenue, 0),
      COALESCE(csv.runtime, 0),
      COALESCE(csv.adult, FALSE),
      CASE
      WHEN COALESCE(csv.backdrop_path, '') = '' THEN ''
      ELSE ':urlbase:' || COALESCE(csv.backdrop_path, '')
      END,
      COALESCE(csv.budget, 0),
      COALESCE(csv.homepage, ''),
      COALESCE(csv.imdb_id, ''),
      COALESCE(csv.original_language, ''),
      COALESCE(csv.original_title, ''),
      COALESCE(csv.overview, ''),
      COALESCE(csv.popularity, 0.0),
      CASE
      WHEN COALESCE(csv.poster_path, '') = '' THEN ''
      ELSE ':urlbase:' || COALESCE(csv.poster_path, '')
      END,
      COALESCE(csv.tagline, ''),
      COALESCE(csv.genres, ''),
      COALESCE(csv.production_companies, ''),
      COALESCE(csv.production_countries, ''),
      COALESCE(csv.spoken_languages, ''),
      COALESCE(csv.keywords, '')
FROM ':filepath:' AS csv WHERE status IN ('Released', 'Post Production') ON CONFLICT DO UPDATE SET duplicates = duplicates + 1`
	)
	var (
		db *sql.DB
	)

	if db, err = cmdmeta.Database(gctx.Context); err != nil {
		return err
	}
	defer db.Close()

	q := template
	q = strings.ReplaceAll(q, ":filepath:", t.Path)
	q = strings.ReplaceAll(q, ":urlbase:", t.URL)

	rs, err := sqlx.Debug(db).ExecContext(gctx.Context, q, t.Source)
	if err != nil {
		return errorsx.Wrap(err, "unable to import known media")
	}

	log.Println("imported", errorsx.Zero(rs.RowsAffected()))

	return nil
}
