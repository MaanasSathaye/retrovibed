package daemons

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/dht/int160"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/james-lawrence/torrent/tracker"
	"github.com/retrovibed/retrovibed/internal/backoffx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/sqlxx"
	"github.com/retrovibed/retrovibed/internal/timex"
	"github.com/retrovibed/retrovibed/internal/torrentx"
	"github.com/retrovibed/retrovibed/tracking"
)

func ResumeDownloads(ctx context.Context, db sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) {
	q := tracking.MetadataSearchBuilder().Where(
		squirrel.And{
			tracking.MetadataQueryInitiated(),
			tracking.MetadataQueryIncomplete(),
			tracking.MetadataQueryNotPaused(),
		},
	)

	iter := sqlx.Scan(tracking.MetadataSearch(ctx, db, q))

	for md := range iter.Iter() {
		log.Println("resuming", md.ID, md.Description, md.Private)
		infopath := rootstore.Path("torrent", fmt.Sprintf("%s.torrent", metainfo.Hash(md.Infohash).String()))

		metadata, err := torrent.New(metainfo.Hash(md.Infohash), torrent.OptionStorage(tstore), torrentx.OptionTracker(md.Tracker), torrentx.OptionInfoFromFile(infopath), torrent.OptionPublicTrackers(md.Private, tracking.PublicTrackers()...))
		if err != nil {
			log.Println(errorsx.Wrapf(err, "unable to create metadata from %s - %s", md.ID, infopath))
			return
		}

		t, added, err := tclient.Start(metadata)
		if err != nil {
			log.Println(errorsx.Wrapf(err, "unable to start download %s - %s", md.ID, infopath))
			continue
		}

		if !added {
			log.Printf("torrent already running %s - %s\n", md.ID, infopath)
			continue
		}

		go func(infopath string, md tracking.Metadata, dl torrent.Torrent) {
			// errorsx.Log(errorsx.Wrap(tracking.Verify(ctx, dl), "failed to verify data"))
			errorsx.Log(errorsx.Wrap(tracking.Download(ctx, db, rootstore, &md, dl), "resume failed"))
			torrentx.RecordInfo(infopath, dl.Metadata())
		}(infopath, md, t)

		log.Println("resumed", md.ID, md.Description)
	}

	errorsx.Log(errorsx.Wrap(iter.Err(), "failed to resume all downloads"))
}

func AnnounceSeeded(ctx context.Context, q sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) {
	const limit = 128

	defer log.Println("announce seeded completed")

	announcer := torrentx.AnnouncerFromClient(tclient)
	nport := tclient.LocalPort()
	pid := tclient.PeerID()

	for {
		select {
		case <-ctx.Done():
			return
		default:
			log.Println("running announcements")
		}

		var seeded []tracking.Metadata

		query := tracking.MetadataSearchBuilder().Where(
			squirrel.And{
				tracking.MetadataQuerySeeding(),
				tracking.MetadataQueryHasTracker(),
				tracking.MetadataQueryNeedsAnnounce(),
			},
		).Limit(limit)

		if err := sqlxx.ScanInto(tracking.MetadataSearch(ctx, q, query), &seeded); err != nil {
			errorsx.Log(errorsx.Wrap(err, "failed to retrieve torrents to announce"))
			continue
		}

		for _, i := range seeded {
			req := tracker.NewAccounceRequest(
				pid,
				nport,
				int160.FromBytes(i.Infohash),
				tracker.AnnounceOptionKey,
				tracker.AnnounceOptionDownloaded(int64(i.Downloaded)),
				tracker.AnnounceOptionUploaded(int64(i.Uploaded)),
				tracker.AnnounceOptionSeeding,
			)

			log.Println("announcing", i.ID, int160.FromBytes(i.Infohash).String())
			announced, err := announcer.ForTracker(i.Tracker).Do(ctx, req)
			if err == tracker.ErrMissingInfoHash {
				errorsx.Log(errorsx.Wrapf(tracking.MetadataDisableAnnounced(ctx, q, i.ID).Scan(&i), "unable to disable announcements for torrent: %s", i.ID))
				continue
			} else if err != nil {
				log.Println("failed to announce seeded torrent", i.ID, int160.FromBytes(i.Infohash).String(), err)
			}

			nextts := time.Now().Add(timex.DurationMax(time.Duration(announced.Interval)*time.Second, 10*time.Minute)).Add(backoffx.Random(5 * time.Minute))

			if err := tracking.MetadataAnnounced(ctx, q, i.ID, nextts).Scan(&i); err != nil {
				log.Println("failed to record announcement", err)
				continue
			}

			log.Println("announced", i.ID, "next", i.NextAnnounceAt, announced.Interval, time.Duration(announced.Interval)*time.Second)
		}

		if len(seeded) >= limit {
			continue
		}

		// we finished announcing, determine when the next announcement is due.
		{
			var (
				err    error
				nextts time.Time
				delay  time.Duration = backoffx.Random(5 * time.Minute)
			)

			query, args, err := tracking.MetadataSearchBuilder().RemoveColumns().Columns("next_announce_at").Where(
				squirrel.And{
					tracking.MetadataQuerySeeding(),
					tracking.MetadataQueryHasTracker(),
					tracking.MetadataQueryAnnounceable(),
				},
			).OrderBy("next_announce_at ASC").Limit(limit).ToSql()
			if err != nil {
				panic(errorsx.Wrap(err, "failed to generate announce query"))
			}

			if nextts, err = sqlx.Timestamp(ctx, q, query, args...); err != nil {
				log.Printf("unable to determine next timestamp - %v", err)
				nextts = time.Now().Add(10 * time.Minute)
			}

			nextts = nextts.Add(delay)

			log.Printf("announce - next will be %v %v\n", delay, nextts)
			time.Sleep(time.Until(nextts))
		}
	}
}
