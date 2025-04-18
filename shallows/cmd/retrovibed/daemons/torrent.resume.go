package daemons

import (
	"context"
	"fmt"
	"log"

	"github.com/Masterminds/squirrel"
	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/sqlxx"
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
