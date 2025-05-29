package daemons

import (
	"context"
	"errors"
	"fmt"
	"iter"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/lucenex"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/retrovibed/retrovibed/tracking"
	"golang.org/x/time/rate"
)

func PrepareDefaultFeeds(ctx context.Context, q sqlx.Queryer) error {
	feedcreate := func(description, url string) (err error) {
		feed := tracking.RSS{
			ID:           md5x.FormatUUID(md5x.Digest(url)),
			Description:  description,
			URL:          url,
			Contributing: true,
		}

		if err = tracking.RSSInsertDefaultFeed(ctx, q, feed).Scan(&feed); err != nil {
			return errorsx.Wrapf(err, "feed creation failed: %s - %s", description, url)
		}

		return nil
	}

	return errors.Join(
		feedcreate("Arch Linux", "https://archlinux.org/feeds/releases/"),
	)
}

// retrieve torrents from rss feeds.
func DiscoverFromRSSFeeds(ctx context.Context, q sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) (err error) {
	const defaultttl = 1440 // 1 day in minutes
	queryfeeds := func(ctx context.Context, done context.CancelCauseFunc) iter.Seq[tracking.RSS] {
		return func(yield func(tracking.RSS) bool) {
			query := tracking.RSSSearchBuilder().Where(
				squirrel.And{
					tracking.RSSQueryNeedsCheck(),
				},
			).Limit(128)

			qiter := sqlx.Scan(tracking.RSSSearch(ctx, q, query))

			for p := range qiter.Iter() {
				if !yield(p) {
					break
				}
			}

			done(qiter.Err())
		}
	}

	bs := backoffx.New(
		backoffx.Exponential(time.Minute),
		backoffx.Maximum(15*time.Minute),
	)

	for attempts := 0; true; attempts++ {
		if c := errorsx.Zero(sqlx.Count(ctx, q, "SELECT COUNT (*) FROM torrents_feed_rss WHERE next_check < NOW()")); c == 0 {
			time.Sleep(bs.Backoff(attempts))
			continue
		} else {
			attempts = -1
		}

		c := httpx.BindRetryTransport(http.DefaultClient, http.StatusTooManyRequests, http.StatusBadGateway)
		l := rate.NewLimiter(rate.Every(3*time.Second), 1)

		fctx, fdone := context.WithCancelCause(ctx)
		for feed := range queryfeeds(fctx, fdone) {
			req, err := http.NewRequestWithContext(ctx, http.MethodGet, feed.URL, nil)
			if err != nil {
				log.Println("unable to build feed request", feed.ID, err)
				continue
			}

			resp, err := httpx.AsError(c.Do(req))
			if err != nil {
				log.Println("unable to retrieve feed", feed.ID, err)
				if err = tracking.RSSCooldownByID(fctx, q, feed.ID, defaultttl, feed.LastBuiltAt).Scan(&feed); err != nil {
					log.Println("unable to mark rss feed for cooldown", err)
				}
				continue
			}

			channel, items, err := rss.Parse(ctx, resp.Body)
			if err != nil {
				log.Println("unable to parse feed", feed.ID, err)
				continue
			}

			if v := channel.LastBuildDate.Timestamp(time.Now()); v.After(feed.LastBuiltAt) {
				log.Println("torrent rss feed has not updated since last check", feed.ID, v, ">=", feed.LastBuiltAt)
				if err = tracking.RSSCooldownByID(fctx, q, feed.ID, langx.DefaultIfZero(defaultttl, channel.TTL), v).Scan(&feed); err != nil {
					log.Println("unable to mark rss feed for cooldown", err)
				}
				continue
			} else {
				log.Println("torrent rss feed changes detected", feed.ID, "fetching", len(items), "torrents")
			}

			for _, item := range items {
				var (
					known library.Known
					meta  tracking.Metadata
				)

				if err = l.Wait(ctx); err != nil {
					log.Println("rate limit failure", err)
					continue
				}

				uri := slicesx.FirstOrDefault(item.Link, rss.FindEnclosureURLByMimetype(mimex.Bittorrent, item)...)

				req, err := http.NewRequestWithContext(ctx, http.MethodGet, uri, nil)
				if err != nil {
					log.Println("unable to build torrent request", feed.ID, err)
					continue
				}

				resp, err := httpx.AsError(http.DefaultClient.Do(req))
				if err != nil {
					log.Println("unable to retrieve feed", feed.ID, err)
					continue
				}

				md, err := metainfo.Load(resp.Body)
				if err != nil {
					log.Println("unable to read metainfo from response", feed.ID, err)
					continue
				}

				mi, err := md.UnmarshalInfo()
				if err != nil {
					log.Println("unable to read info from metadata", feed.ID, err)
					continue
				}

				encoded, err := metainfo.Encode(md)
				if err != nil {
					log.Println("unable to encode torrent for persistence", feed.ID, err)
					continue
				}

				if err = os.WriteFile(rootstore.Path("torrent", fmt.Sprintf("%s.torrent", md.HashInfoBytes().HexString())), encoded, 0600); err != nil {
					log.Println("unable to persist torrent to disk", feed.ID, err)
					continue
				}

				if known, err = library.DetectKnownMedia(ctx, q, lucenex.Clean(mi.Name)); err != nil {
					log.Println("unable to detect known media ignoring", err)
				}

				if err = tracking.MetadataInsertWithDefaults(
					ctx, q, tracking.NewMetadata(
						langx.Autoptr(md.HashInfoBytes()),
						tracking.MetadataOptionFromInfo(&mi),
						tracking.MetadataOptionDescription(stringsx.FirstNonBlank(mi.Name, item.Title)),
						tracking.MetadataOptionTrackers(md.Announce),
						tracking.MetadataOptionKnownMediaID(known.UID),
						tracking.MetadataOptionAutoDescription,
					)).Scan(&meta); err != nil {
					log.Println("unable to record torrent metadata", feed.ID, err)
					continue
				}

				if feed.Autodownload {
					// log.Println("marking torrent to be automatically downloaded", meta.Description, feed.Autodownload)
					if err = tracking.MetadataDownloadByID(ctx, q, meta.ID).Scan(&meta); err != nil {
						log.Println("unable to mark torrent for automatic download", err)
						continue
					}
				}
				// log.Println("recorded", feed.ID, meta.ID, meta.Description)
			}

			if updated := stringsx.FirstNonBlank(feed.Description, channel.Title); updated != feed.Description {
				feed.Description = updated
				if cause := tracking.RSSInsertWithDefaults(fctx, q, feed).Scan(&feed); cause != nil {
					log.Println("failed to update rss feed", cause)
					continue
				}
			} else {
				if err = tracking.RSSCooldownByID(fctx, q, feed.ID, langx.DefaultIfZero(defaultttl, channel.TTL), channel.LastBuildDate.Timestamp(time.Now())).Scan(&feed); err != nil {
					log.Println("unable to mark rss feed for cooldown", err)
					continue
				}
			}

			// log.Println("starting any downloads", feed.Description)
			// begin any torrent provided by this feed
			ResumeDownloads(ctx, q, rootstore, tclient, tstore)
		}

		if err := fctx.Err(); contextx.IgnoreCancelled(err) != nil {
			return err
		}

		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
		}
	}

	return nil
}
