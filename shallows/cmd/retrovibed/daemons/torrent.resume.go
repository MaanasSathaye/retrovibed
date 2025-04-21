package daemons

import (
	"context"
	"fmt"
	"log"
	"time"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
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

	err := sqlxx.ScanEach(tracking.MetadataSearch(ctx, db, q), func(md *tracking.Metadata) error {
		log.Println("resuming", md.ID, md.Description, md.Private)
		infopath := rootstore.Path("torrent", fmt.Sprintf("%s.torrent", metainfo.Hash(md.Infohash).HexString()))

		autotrackers := torrent.OptionNoop
		if !md.Private {
			autotrackers = torrent.OptionTrackers(tracking.PublicTrackers()...)
		}

		metadata, err := torrent.New(metainfo.Hash(md.Infohash), torrent.OptionStorage(tstore), torrent.OptionTrackers(md.Tracker), torrentx.OptionInfoFromFile(infopath), autotrackers)
		if err != nil {
			return errorsx.Wrapf(err, "unable to create metadata from %s - %s", md.ID, infopath)
		}

		t, added, err := tclient.Start(metadata)
		if err != nil {
			log.Println(errorsx.Wrapf(err, "unable to start download %s - %s", md.ID, infopath))
			return nil
		}

		if !added {
			log.Printf("torrent already running %s - %s\n", md.ID, infopath)
			return nil
		}

		go func(infopath string, md *tracking.Metadata, dl torrent.Torrent) {
			// errorsx.Log(errorsx.Wrap(tracking.Verify(ctx, dl), "failed to verify data"))
			errorsx.Log(errorsx.Wrap(tracking.Download(ctx, db, rootstore, md, dl), "resume failed"))
			torrentx.RecordInfo(infopath, dl.Metadata())
		}(infopath, md, t)

		log.Println("resumed", md.ID, md.Description)
		return nil
	})

	errorsx.Log(errorsx.Wrap(err, "failed to resume all downloads"))
}

func AnnounceSeeded(ctx context.Context, q sqlx.Queryer, rootstore fsx.Virtual, tclient *torrent.Client, tstore storage.ClientImpl) {
	const limit = 128

	announcer := torrentx.AnnouncerFromClient(tclient)
	nport := tclient.LocalPort()
	pid := int160.FromByteArray(tclient.PeerID())

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

			nextts := time.Now().Add(timex.DurationMax(time.Duration(announced.Interval)*time.Second, time.Hour))
			if err := tracking.MetadataAnnounced(ctx, q, i.ID, nextts).Scan(&i); err != nil {
				log.Println("failed to record announcement", err)
				continue
			}

			log.Println("announced", i.ID, "next", i.NextAnnounceAt)
		}

		if len(seeded) >= limit {
			continue
		}

		// we finished announcing, determine when the next announcement is due.
		{
			var (
				err    error
				nextts time.Time
				delay  time.Duration
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
				delay = backoffx.DynamicHash15m(uuid.Must(uuid.NewV4()).String())
				log.Printf("unable to determine next timestamp - %v", err)
				nextts = time.Now().Add(delay)
			}

			log.Printf("announce - next will be %v %v\n", delay, nextts)
			time.Sleep(time.Until(nextts))
		}
	}
}
