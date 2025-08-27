package cmdmedia

import (
	"encoding/binary"
	"fmt"
	"iter"
	"log"
	"math"
	"os"
	"strconv"
	"time"

	"github.com/dashotv/tvdb"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"
)

type tvdbimport struct {
	APIKey string  `flag:"" name:"apikey" help:"api key for requests" require:"true"`
	URL    string  `flag:"" name:"baseurl" help:"url base for image assets" default:"https://thetvdb.com"`
	Source string  `flag:"" name:"source" help:"short id for the data source" hidden:"true" default:"tvdb"`
	Limit  float64 `flag:"" name:"maxpage" help:"maximum page to retrieve"`
	cause  error
}

func (t tvdbimport) imgpath(s string) string {
	if stringsx.Blank(s) {
		return ""
	}

	return fmt.Sprintf("%s%s", t.URL, s)
}

func (t *tvdbimport) records(c *tvdb.Client) iter.Seq[library.Known] {
	return func(yield func(library.Known) bool) {
		epochts := time.Unix(0, 0).Format(time.DateOnly)

		for i := 0.; i < langx.FirstNonZero(t.Limit, math.MaxFloat64); i++ {
			page, err := c.GetAllSeries(langx.Autoptr(i))
			if err != nil {
				t.cause = errorsx.Wrap(err, "failed to discover records")
				return
			}
			log.Println("DERP DERP 0", langx.Autoderef(page.Links.Next), langx.Autoderef(page.Data[0].Name), langx.Autoderef(page.Data[0].FirstAired))
			for _, mr := range page.Data {
				if stringsx.Blank(langx.Autoderef(mr.Image)) {
					log.Println("skipping", langx.Autoderef(mr.Name), "missing poster")
					continue
				}

				_md5 := md5x.JSON(mr)
				uidmd5 := uuid.FromBytesOrNil(_md5.Sum(nil))

				v := library.Known{
					Source:           t.Source,
					UID:              library.KnownImportedUintID(t.Source, uint64(langx.Autoderef(mr.ID))),
					Md5:              uidmd5.String(),
					Md5Lower:         binary.LittleEndian.Uint64(uuidx.LowN(uidmd5, 64)),
					ID:               strconv.FormatInt(int64(langx.Autoderef(mr.ID)), 10),
					OriginalLanguage: langx.Autoderef(mr.OriginalLanguage),
					OriginalTitle:    langx.Autoderef(mr.Name),
					Overview:         langx.Autoderef(mr.Overview),
					Popularity:       max(langx.Autoderef(mr.Score)/100000, 1.0),
					PosterPath:       t.imgpath(langx.Autoderef(mr.Image)),
					Title:            langx.Autoderef(mr.Name),
					Released:         errorsx.Zero(time.Parse(time.DateOnly, langx.FirstNonZero(langx.Autoderef(mr.FirstAired), epochts))),
				}

				if !yield(v) {
					return
				}
			}
		}
	}
}

func (t tvdbimport) Run(gctx *cmdopts.Global) (err error) {
	c, err := tvdb.Login(t.APIKey)
	if err != nil {

		return errorsx.Wrap(err, "unable to initialize tvdb client")
	}

	encoder := jsonl.NewEncoder(os.Stdout)

	for v := range t.records(c) {
		if err := encoder.Encode(v); err != nil {
			return errorsx.Wrap(err, "unable to encode media")
		}
	}

	return t.cause
}
