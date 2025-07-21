package cmdmedia

import (
	"encoding/binary"
	"fmt"
	"log"
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
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"

	tmdb "github.com/cyruzin/golang-tmdb"
)

type tmdbimport struct {
	APIKey string `flag:"" name:"apikey" help:"api key for requests" require:"true"`
	URL    string `flag:"" name:"baseurl" help:"url base for image assets" default:"https://image.tmdb.org/t/p/original"`
}

func (t tmdbimport) Run(gctx *cmdopts.Global) (err error) {
	var (
		resp *tmdb.DiscoverMovie
	)
	c, err := tmdb.Init(t.APIKey)
	if err != nil {
		return errorsx.Wrap(err, "unable to initialize tmdb client")
	}
	c.SetClientAutoRetry()

	imgpath := func(s string) string {
		if stringsx.Blank(s) {
			return ""
		}

		return fmt.Sprintf("%s%s", t.URL, s)
	}

	year := time.Date(1900, time.January, 1, 0, 0, 0, 0, time.UTC)
	cyear := time.Now().Year()
	encoder := jsonl.NewEncoder(os.Stdout)
	for page := int64(1); ; {
		resp, err = c.GetDiscoverMovie(map[string]string{
			"include_adult":        "true",
			"page":                 strconv.FormatInt(page, 10),
			"primary_release_year": year.Format(time.DateOnly),
			"sort_by":              "primary_release_date.asc",
		})

		if err != nil {
			return errorsx.Wrap(err, "unable to initialize tmdb client")
		}

		for _, mr := range resp.Results {
			_md5 := md5x.JSON(mr)
			uidmd5 := uuid.FromBytesOrNil(_md5.Sum(nil))
			if err := encoder.Encode(library.Known{
				UID:              library.KnownImportedUintID("tmdb", uint64(mr.ID)),
				Md5:              uidmd5.String(),
				Md5Lower:         binary.LittleEndian.Uint64(uuidx.LowN(uidmd5, 64)),
				ID:               strconv.FormatInt(mr.ID, 10),
				Adult:            mr.Adult,
				BackdropPath:     imgpath(mr.BackdropPath),
				OriginalLanguage: mr.OriginalLanguage,
				OriginalTitle:    mr.OriginalTitle,
				Overview:         mr.Overview,
				Popularity:       float64(mr.Popularity),
				PosterPath:       imgpath(mr.PosterPath),
				Title:            mr.Title,
				VoteAverage:      float64(mr.VoteAverage),
				VoteCount:        mr.VoteCount,
			}); err != nil {
				return errorsx.Wrap(err, "unable to encode media")
			}
		}

		year = slicesx.LastOrDefault(year, slicesx.MapTransform(func(mr tmdb.MovieResult) time.Time { return errorsx.Must(time.Parse(time.DateOnly, mr.ReleaseDate)) }, resp.Results...)...)
		page = resp.Page
		if page == resp.TotalPages && cyear == year.Year() {
			log.Println("DERP DERP", page, resp.TotalPages, cyear, year.Year())
			break
		}

	}

	return nil
}
