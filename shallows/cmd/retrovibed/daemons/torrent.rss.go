package daemons

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"iter"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/contextx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/slicesx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/rss"
	"github.com/retrovibed/retrovibed/tracking"
	"golang.org/x/time/rate"
)

func PrepareDefaultFeeds(ctx context.Context, q sqlx.Queryer) error {
	var (
		feeds []tracking.RSS
	)

	log.Println("syncing default rss feeds initialized")
	defer log.Println("syncing default rss feeds completed")

	encoded, err := fsx.AutoCached(userx.DefaultConfigDir(userx.DefaultRelRoot(), "default.feeds.json"), func() (_ []byte, _ error) {
		return json.Marshal([]tracking.RSS{
			{
				Description:  "Arch Linux - iso",
				URL:          "https://archlinux.org/feeds/releases/",
				Contributing: true,
			},
			{
				Description:  "Retrovibed - test data (enable autoarchive to provide a small bonus to the developers)",
				URL:          "https://vibed.community.retrovibe.space",
				Contributing: true,
				Autodownload: true,
			},
			{
				Description:  "Retrovibed - media metadata updates. posters, ratings, descriptions",
				URL:          "https://media.community.retrovibe.space",
				Contributing: true,
				Autodownload: true,
			},
		})
	})
	if err != nil {
		return err
	}

	if err = json.Unmarshal(encoded, &feeds); err != nil {
		return err
	}

	for _, feed := range feeds {
		feed = langx.Clone(feed, tracking.RSSOptionDefaultFeeds(feed), tracking.RSSOptionDefaultEncryptionSeed)
		if err = tracking.RSSInsertDefaultFeed(ctx, q, feed).Scan(&feed); err != nil {
			return errorsx.Wrapf(err, "feed creation failed: %s - %s", feed.Description, feed.URL)
		}
	}

	return nil
}

func DiscoverFromRSSFeedsOnce(ctx context.Context, q sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) (err error) {
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

		if v := channel.LastBuildDate.Timestamp(time.Now()); v.Before(feed.LastBuiltAt) || v.Equal(feed.LastBuiltAt) {
			log.Println("torrent rss feed has not updated since last check", feed.ID, channel.TTL, v, "<", feed.LastBuiltAt)
			if err = tracking.RSSCooldownByID(fctx, q, feed.ID, langx.DefaultIfZero(defaultttl, channel.TTL), v).Scan(&feed); err != nil {
				log.Println("unable to mark rss feed for cooldown", err)
			}
			continue
		} else {
			log.Println("torrent rss feed changes detected", feed.ID, "fetching", len(items), "torrents", v, ">", feed.LastBuiltAt)
		}

		handlehttp := func(uri rss.Enclosure, i rss.Item) error {
			var (
				known library.Known
				meta  tracking.Metadata
			)

			if !(strings.HasPrefix(uri.URL, "http") || strings.HasPrefix(uri.URL, "https")) {
				return nil
			}

			if err = l.Wait(ctx); err != nil {
				return errorsx.Wrap(err, "rate limited")
			}

			log.Println("handling", channel.Retrovibed.Entropy, channel.Retrovibed.Mimetype, uri)

			req, err := http.NewRequestWithContext(ctx, http.MethodGet, uri.URL, nil)
			if err != nil {
				return errorsx.Wrapf(err, "unable to build torrent request: %s", feed.ID)
			}

			resp, err := httpx.AsError(http.DefaultClient.Do(req))
			if err != nil {
				return errorsx.Wrapf(err, "unable to retrieve feed: %s", feed.ID)
			}

			buf, err := io.ReadAll(resp.Body)
			if err != nil {
				return errorsx.Wrapf(err, "unable to read metainfo from response: %s", feed.ID)
			}

			md, err := metainfo.Load(bytes.NewReader(buf))
			if err != nil {
				return errorsx.Wrapf(err, "unable to read metainfo from response: %s", feed.ID)
			}

			mi, err := md.UnmarshalInfo()
			if err != nil {
				return errorsx.Wrapf(err, "unable to read info from metadata: %s", feed.ID)
			}

			if err = os.WriteFile(rootstore.Path("torrent", fmt.Sprintf("%s.torrent", md.HashInfoBytes().String())), buf, 0600); err != nil {
				return errorsx.Wrapf(err, "unable to persist torrent to disk: %s", feed.ID)
			}

			if known, err = library.DetectKnownMedia(ctx, q, mi.Name); err != nil {
				log.Println("unable to detect known media ignoring", err)
			}

			if err = tracking.MetadataInsertWithDefaults(
				ctx, q, tracking.NewMetadata(
					langx.Autoptr(md.HashInfoBytes()),
					tracking.MetadataOptionFromInfo(&mi),
					tracking.MetadataOptionDescription(stringsx.FirstNonBlank(mi.Name, i.Title)),
					tracking.MetadataOptionTrackers(md.Announce),
					tracking.MetadataOptionKnownMediaID(known.UID),
					tracking.MetadataOptionMimetype(stringsx.FirstNonBlank(channel.Retrovibed.Mimetype, uri.Mimetype)),
					tracking.MetadataOptionEntropySeed(
						md.HashInfoBytes().Bytes(),
						uuidx.FirstNonNil(
							uuid.FromStringOrNil(feed.EncryptionSeed),
							uuid.FromStringOrNil(channel.Retrovibed.Entropy),
						).Bytes(),
					),
					tracking.MetadataOptionAutoDescription,
					tracking.MetadataOptionAutoArchive(feed.Autoarchive),
				)).Scan(&meta); err != nil {
				return errorsx.Wrapf(err, "unable to record torrent metadata: %s", feed.ID)
			}

			if feed.Autodownload {
				// log.Println("marking torrent to be automatically downloaded", meta.Description, feed.Autodownload)
				if err = tracking.MetadataAutoDownloadByID(ctx, q, meta.ID).Scan(&meta); err != nil {
					return errorsx.Wrapf(err, "unable to mark torrent for automatic download: %s", feed.ID)
				}
			}

			return nil
		}

		handlemagnet := func(uri rss.Enclosure, i rss.Item) error {
			var (
				known library.Known
				meta  tracking.Metadata
			)

			if !strings.HasPrefix(uri.URL, "magnet") {
				return nil
			}

			log.Println("handling", channel.Retrovibed.Entropy, channel.Retrovibed.Mimetype, uri)
			md, err := metainfo.ParseMagnetURI(uri.URL)
			if err != nil {
				return errorsx.Wrapf(err, "unable to parse magnet link: %s", feed.ID)
			}

			if known, err = library.DetectKnownMedia(ctx, q, md.DisplayName); err != nil {
				log.Println("unable to detect known media ignoring", err)
			}

			if err = tracking.MetadataInsertWithDefaults(
				ctx, q, tracking.NewMetadata(
					langx.Autoptr(md.InfoHash),
					tracking.MetadataOptionFromMagnet(&md),
					tracking.MetadataOptionBytes(uri.Length),
					tracking.MetadataOptionMimetype(stringsx.FirstNonBlank(channel.Retrovibed.Mimetype, uri.Mimetype)),
					tracking.MetadataOptionDescription(i.Title),
					tracking.MetadataOptionKnownMediaID(known.UID),
					tracking.MetadataOptionEntropySeed(
						md.InfoHash.Bytes(),
						uuidx.FirstNonNil(
							uuid.FromStringOrNil(feed.EncryptionSeed),
							uuid.FromStringOrNil(channel.Retrovibed.Entropy),
						).Bytes(),
					),
					tracking.MetadataOptionAutoArchive(feed.Autoarchive),
					tracking.MetadataOptionAutoDescription,
				)).Scan(&meta); err != nil {
				return errorsx.Wrapf(err, "unable to record torrent metadata: %s", feed.ID)
			}

			if feed.Autodownload {
				// log.Println("marking torrent to be automatically downloaded", meta.Description, feed.Autodownload)
				if err = tracking.MetadataAutoDownloadByID(ctx, q, meta.ID).Scan(&meta); err != nil {
					return errorsx.Wrapf(err, "unable to mark torrent for automatic download: %s", feed.ID)
				}
			}

			return nil
		}

		for _, item := range items {
			// this doesnt work as expected. its not the addition to the channel its the date it was published.
			// if item.PublishDate.Before(feed.LastBuiltAt) || item.PublishDate.Equal(feed.LastBuiltAt) {
			// 	log.Println("item before last built date", item.PublishDate, "<=", feed.LastBuiltAt)
			// 	continue
			// }

			uri := slicesx.FirstOrDefault(rss.ItemToEnclosure(item, mimex.Bittorrent), rss.FindEnclosureURLByMimetype(mimex.Bittorrent, item)...)

			if err := handlehttp(uri, item); err != nil {
				log.Println(err)
				continue
			}

			if err := handlemagnet(uri, item); err != nil {
				log.Println(err)
				continue
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

	return nil
}

// retrieve torrents from rss feeds.
func DiscoverFromRSSFeeds(ctx context.Context, q sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) (err error) {
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

		if err := DiscoverFromRSSFeedsOnce(ctx, q, rootstore, tclient, tstore); err != nil {
			log.Println("failed to discover torrents", err)
			continue
		}

		select {
		case <-ctx.Done():
			return context.Cause(ctx)
		default:
		}
	}

	return nil
}
