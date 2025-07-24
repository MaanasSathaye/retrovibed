package cmdmedia

import (
	"encoding/binary"
	"fmt"
	"iter"
	"math"
	"os"
	"strconv"
	"time"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"

	tmdb "github.com/cyruzin/golang-tmdb"
)

type tmdbimport struct {
	APIKey  string    `flag:"" name:"apikey" help:"api key for requests" require:"true"`
	URL     string    `flag:"" name:"baseurl" help:"url base for image assets" default:"https://image.tmdb.org/t/p/original"`
	StartAt time.Time `flag:"" name:"start" help:"date to start retrieving data from, format: 2006-01-02" format:"2006-01-02" default:"1900-01-01"`
	EndAt   time.Time `flag:"" name:"end" help:"date to end retrieving data from, format: 2006-01-02" format:"2006-01-02" default:"${vars_date_started}"`
	Source  string    `flag:"" name:"source" help:"short id for the data source" hidden:"true" default:"tmdb"`
	cause   error
}

func (t tmdbimport) imgpath(s string) string {
	if stringsx.Blank(s) {
		return ""
	}

	return fmt.Sprintf("%s%s", t.URL, s)
}

func (t *tmdbimport) movies(c *tmdb.Client) iter.Seq[library.Known] {
	return func(yield func(library.Known) bool) {
		var (
			resp *tmdb.DiscoverMovie = &tmdb.DiscoverMovie{
				PaginatedResultsMeta: tmdb.PaginatedResultsMeta{
					TotalResults: math.MaxInt64,
					TotalPages:   math.MaxInt64,
				},
			}
		)

		year := t.StartAt
		cyear := t.EndAt.Add(24 * time.Hour)

		for page := int64(1); cyear.After(year); {
			var (
				err error
			)

			resp, err = c.GetDiscoverMovie(map[string]string{
				"include_adult":            "true",
				"page":                     strconv.FormatInt(page, 10),
				"primary_release_date.gte": year.Format(time.DateOnly),
				"primary_release_date.lte": year.Format(time.DateOnly),
				"sort_by":                  "primary_release_date.asc",
			})

			if err != nil {
				t.cause = errorsx.Wrap(err, "failed to discover movies")
				return
			}

			for _, mr := range resp.Results {
				_md5 := md5x.JSON(mr)
				uidmd5 := uuid.FromBytesOrNil(_md5.Sum(nil))
				v := library.Known{
					Source:           t.Source,
					UID:              library.KnownImportedUintID(t.Source, uint64(mr.ID)),
					Md5:              uidmd5.String(),
					Md5Lower:         binary.LittleEndian.Uint64(uuidx.LowN(uidmd5, 64)),
					ID:               strconv.FormatInt(mr.ID, 10),
					Adult:            mr.Adult,
					BackdropPath:     t.imgpath(mr.BackdropPath),
					OriginalLanguage: mr.OriginalLanguage,
					OriginalTitle:    mr.OriginalTitle,
					Overview:         mr.Overview,
					Popularity:       float64(mr.Popularity),
					PosterPath:       t.imgpath(mr.PosterPath),
					Title:            mr.Title,
					Released:         errorsx.Zero(time.Parse(time.DateOnly, mr.ReleaseDate)),
				}

				if !yield(v) {
					return
				}
			}

			year = slicesx.LastOrDefault(year, slicesx.MapTransform(func(mr tmdb.MovieResult) time.Time {
				return timex.Max(errorsx.Zero(time.Parse(time.DateOnly, mr.ReleaseDate)), year)
			}, resp.Results...)...)

			if page >= resp.TotalPages {
				year = year.Add(24 * time.Hour)
				page = 1
			} else {
				page = resp.Page + 1
			}
		}
	}
}

func (t *tmdbimport) series(c *tmdb.Client) iter.Seq[library.Known] {
	return func(yield func(library.Known) bool) {
		var (
			resp *tmdb.DiscoverTV = &tmdb.DiscoverTV{
				PaginatedResultsMeta: tmdb.PaginatedResultsMeta{
					TotalResults: math.MaxInt64,
					TotalPages:   math.MaxInt64,
				},
			}
		)

		year := t.StartAt
		cyear := t.EndAt.Add(24 * time.Hour)

		for page := int64(1); cyear.After(year); {
			var (
				err error
			)

			resp, err = c.GetDiscoverTV(map[string]string{
				"include_adult":      "true",
				"page":               strconv.FormatInt(page, 10),
				"first_air_date.gte": year.Format(time.DateOnly),
				"first_air_date.lte": year.Format(time.DateOnly),
				"sort_by":            "first_air_date.asc",
			})

			if err != nil {
				t.cause = errorsx.Wrap(err, "failed to discover movies")
				return
			}

			for _, mr := range resp.Results {
				_md5 := md5x.JSON(mr)
				uidmd5 := uuid.FromBytesOrNil(_md5.Sum(nil))

				v := library.Known{
					UID:              library.KnownImportedUintID(t.Source, uint64(mr.ID)),
					Source:           t.Source,
					Md5:              uidmd5.String(),
					Md5Lower:         binary.LittleEndian.Uint64(uuidx.LowN(uidmd5, 64)),
					ID:               strconv.FormatInt(mr.ID, 10),
					BackdropPath:     t.imgpath(mr.BackdropPath),
					OriginalLanguage: mr.OriginalLanguage,
					OriginalTitle:    mr.OriginalName,
					Overview:         mr.Overview,
					Popularity:       float64(mr.Popularity),
					PosterPath:       t.imgpath(mr.PosterPath),
					Title:            mr.Name,
					Adult:            mr.Adult,
					Released:         errorsx.Zero(time.Parse(time.DateOnly, mr.FirstAirDate)),
				}

				if !yield(v) {
					return
				}
			}

			year = slicesx.LastOrDefault(year, slicesx.MapTransform(func(mr tmdb.TVShowResult) time.Time {
				return timex.Max(errorsx.Zero(time.Parse(time.DateOnly, mr.FirstAirDate)), year)
			}, resp.Results...)...)

			if page == resp.TotalPages {
				year = year.Add(24 * time.Hour)
				page = 1
			} else {
				page = resp.Page + 1
			}
		}
	}
}

func (t tmdbimport) Run(gctx *cmdopts.Global) (err error) {
	c, err := tmdb.Init(t.APIKey)
	if err != nil {
		return errorsx.Wrap(err, "unable to initialize tmdb client")
	}
	c.SetClientAutoRetry()

	encoder := jsonl.NewEncoder(os.Stdout)

	for v := range t.movies(c) {
		if err := encoder.Encode(v); err != nil {
			return errorsx.Wrap(err, "unable to encode media")
		}
	}

	for v := range t.series(c) {
		if err := encoder.Encode(v); err != nil {
			return errorsx.Wrap(err, "unable to encode media")
		}
	}

	return t.cause
}
