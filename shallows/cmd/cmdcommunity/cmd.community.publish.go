package cmdcommunity

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"iter"
	"os"
	"time"

	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/jsonl"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/media"
	"github.com/retrovibed/retrovibed/metaapi"
	"github.com/retrovibed/retrovibed/rss"
)

type cmdCommunityPublish struct {
	Title       string        `flag:"" name:"title" help:"title of the rss feed, defaults to the community name"`
	Description string        `flag:"" name:"description" help:"description of the rss feed, defaults to the community description"`
	Timestamp   time.Time     `flag:"" name:"publish date" help:"pub date for the feed" default:"${vars_timestamp_started}"`
	TTL         time.Duration `flag:"" name:"ttl" help:"frequency clients should check the feed in minutes" default:"1440m"`
	Copyright   string        `flag:"" name:"copyright" help:"copyright for the rss feed" default:""`
	DryRun      bool          `flag:"" name:"dry-run" help:"do not upload just generate"`
	Name        string        `arg:"" name:"name" help:"name of the community to upload the feed" required:"true"`
}

func (t cmdCommunityPublish) items(r io.Reader) iter.Seq[rss.Item] {
	ts := time.Now()
	return func(yield func(rss.Item) bool) {
		var (
			derr error
			v    media.Published
		)
		d := jsonl.NewDecoder(r)

		for derr = d.Decode(&v); derr == nil; derr = d.Decode(&v) {
			uri := metainfo.Magnet{
				InfoHash:    metainfo.Hash(errorsx.Must(int160.FromHexEncodedString(v.Id)).AsByteArray()),
				DisplayName: v.Description,
			}
			if !yield(rss.Item{
				Guid:        v.Id,
				Title:       v.Description,
				PublishDate: ts,
				Enclosures: []rss.Enclosure{
					{URL: uri.String(), Mimetype: mimex.Bittorrent, Length: v.Bytes},
				},
			}) {
				return
			}
		}

		if errorsx.Ignore(derr, io.EOF) != nil {
			panic(derr)
		}
	}
}

func (t cmdCommunityPublish) Run(gctx *cmdopts.Global) (err error) {
	var (
		buf bytes.Buffer
	)
	if err := metaapi.Register(gctx.Context); err != nil {
		return errorsx.Wrap(err, "unable to register with archival service")
	}

	c, err := metaapi.AutoJWTClient(gctx.Context)
	if err != nil {
		return errorsx.Wrap(err, "unable to create api client")
	}

	community, err := metaapi.CommunityInfo(gctx.Context, c, t.Name)
	if err != nil {
		return errorsx.Wrap(err, "failed to retrieve community metadata")
	}

	err = errorsx.Wrap(rss.Generator().Generate(io.MultiWriter(&buf), rss.Channel{
		Link:          fmt.Sprintf("https://%s.community.retrovibe.space/", t.Name),
		TTL:           int(t.TTL.Minutes()),
		Title:         stringsx.FirstNonBlank(t.Title, community.Community.Domain),
		LastBuildDate: t.Timestamp,
		Language:      "en-us",
		Description:   stringsx.FirstNonBlank(t.Description, community.Community.Description),
		Copyright:     t.Copyright,
		Retrovibed:    &rss.Retrovibed{Mimetype: community.Community.Mimetype, Entropy: community.Community.Entropy},
	}, t.items(os.Stdin)), "failed to generate rss feed")
	if err != nil {
		return err
	}

	if t.DryRun {
		_, err = io.Copy(os.Stdout, &buf)
		return err
	}

	uploaded, err := metaapi.CommunityPublish(gctx.Context, c, community.Community.Id, &buf)
	if err != nil {
		return err
	}

	if err = json.NewEncoder(os.Stdout).Encode(uploaded.Community); err != nil {
		return errorsx.Wrap(err, "unable to write to uploaded")
	}

	return nil
}
