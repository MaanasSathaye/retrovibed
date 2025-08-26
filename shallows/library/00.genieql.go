//go:build genieql.generate
// +build genieql.generate

package library

import (
	"context"
	"time"

	genieql "github.com/james-lawrence/genieql/ginterp"
	"github.com/retrovibed/retrovibed/internal/sqlx"
)

func Metadata(gql genieql.Structure) {
	gql.From(
		gql.Table("library_metadata"),
	)
}

func MetadataScanner(gql genieql.Scanner, pattern func(i Metadata)) {
	gql.ColumnNamePrefix("library_metadata.")
}

func MetadataInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Metadata) NewMetadataScannerStaticRow,
) {
	gql.Into("library_metadata").Default("created_at", "updated_at", "hidden_at", "tombstoned_at").Conflict("ON CONFLICT (id) DO UPDATE SET updated_at = DEFAULT, archive_id = CASE WHEN archive_id IN ('ffffffff-ffff-ffff-ffff-ffffffffffff', '00000000-0000-0000-0000-000000000000') THEN EXCLUDED.archive_id ELSE archive_id END")
}

func MetadataDeleteByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`DELETE FROM library_metadata WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataArchivedByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id, aid string, quota uint64) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET archive_id = {aid}, quota_usage = {quota} WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataHideByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET hidden_at = NOW(), initiated_at = 'infinity' WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataUpdateAutodescriptionByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string, autodescription string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET updated_at = NOW(), auto_description = {autodescription} WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataUpdateDescriptionByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string, description string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET updated_at = NOW(), description = {description} WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataFindByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + MetadataScannerStaticColumns + ` FROM library_metadata WHERE "id" = {id}`)
}

func MetadataTombstoneByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET tombstoned_at = NOW() WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataTombstoneByTorrentID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, tid string) NewMetadataScannerStatic,
) {
	gql = gql.Query(`UPDATE library_metadata SET tombstoned_at = NOW() WHERE "torrent_id" = {tid} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataFindByDescription(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, desc string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + MetadataScannerStaticColumns + ` FROM library_metadata WHERE "description" = {desc}`)
}

func MetadataAssociateTorrent(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, desc, tid string) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET torrent_id = {tid} WHERE "description" = {desc} AND torrent_id = '00000000-0000-0000-0000-000000000000' RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataUpdate(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string, md Metadata) NewMetadataScannerStaticRow,
) {
	gql = gql.Query(`UPDATE library_metadata SET description = {md.Description}, known_media_id = {md.KnownMediaID}, archive_id = {md.ArchiveID} WHERE "id" = {id} RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataTransferKnownMediaIDFromTorrent(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, ts time.Time) NewMetadataScannerStatic,
) {
	gql = gql.Query(`UPDATE library_metadata SET updated_at = NOW(), known_media_id = t.known_media_id FROM torrents_metadata AS t WHERE t.id = library_metadata.torrent_id AND t."updated_at" >= {ts} AND library_metadata.known_media_id = 'ffffffff-ffff-ffff-ffff-ffffffffffff' AND t.known_media_id NOT IN ('ffffffff-ffff-ffff-ffff-ffffffffffff', '00000000-0000-0000-0000-000000000000') RETURNING ` + MetadataScannerStaticColumns)
}

// used to sync known media idea from a known torrent.metadata to every media with that torrent.metadata.
func MetadataSyncKnownMediaIDFromTorrent(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, tid string) NewMetadataScannerStatic,
) {
	gql = gql.Query(`UPDATE library_metadata SET updated_at = NOW(), known_media_id = torrents_metadata.known_media_id FROM torrents_metadata WHERE torrents_metadata."id" = {tid} AND torrents_metadata."id" = library_metadata.torrent_id RETURNING ` + MetadataScannerStaticColumns)
}

func MetadataForTorrentArchiveRetrieval(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, infohash []byte, offset uint64, length uint64) NewMetadataScannerStatic,
) {
	gql = gql.Query(`SELECT ` + MetadataScannerStaticColumns + ` FROM library_metadata INNER JOIN torrents_metadata AS tmd ON library_metadata.torrent_id = tmd.id WHERE to_hex(tmd.infohash) = to_hex({infohash}) AND {offset} BETWEEN disk_offset AND library_metadata.bytes AND library_metadata.archive_id NOT IN ('ffffffff-ffff-ffff-ffff-ffffffffffff', '00000000-0000-0000-0000-000000000000')`)
}

func ScoredScanner(gql genieql.Scanner, pattern func(relevance float64)) {
}

func Known(gql genieql.Structure) {
	gql.From(
		gql.Table("library_known_media"),
	)
}

func KnownScanner(gql genieql.Scanner, pattern func(i Known)) {
	gql.ColumnNamePrefix("library_known_media.")
}

func KnownInsertWithDefaults(
	gql genieql.Insert,
	pattern func(ctx context.Context, q sqlx.Queryer, a Known) NewKnownScannerStaticRow,
) {
	gql.Into("library_known_media").Default("created_at").Conflict("ON CONFLICT (uid) DO UPDATE SET title = EXCLUDED.title, original_language = EXCLUDED.original_language, original_title = EXCLUDED.original_title, popularity = EXCLUDED.popularity, overview = EXCLUDED.overview, source = EXCLUDED.source, poster_path = EXCLUDED.poster_path, backdrop_path = EXCLUDED.backdrop_path, duplicates = duplicates + 1")
}

func KnownFindByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, id string) NewKnownScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + KnownScannerStaticColumns + ` FROM library_known_media WHERE "uid" = {id}`)
}

func KnownFindByLastCreated(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer) NewKnownScannerStaticRow,
) {
	gql = gql.Query(`SELECT ` + KnownScannerStaticColumns + ` FROM library_known_media ORDER BY created_at DESC LIMIT 1`)
}

func KnownScoreByID(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, uid string, terms string) NewScoredScannerStaticRow,
) {
	gql = gql.Query(`SELECT COALESCE(fts_main_library_known_media.match_bm25(md5_lower, {terms}), 0.0)::float AS relevance FROM library_known_media WHERE uid = {uid}`)
}

func KnownBestMatch(
	gql genieql.Function,
	pattern func(ctx context.Context, q sqlx.Queryer, terms string, cutoff float32) NewKnownScannerStaticRow,
) {
	gql = gql.Query(`WITH scored AS (SELECT uid, {terms} as q, (jaro_winkler_similarity(title, q, {cutoff}) + jaro_similarity(title, q, {cutoff})) / 2 AS relevance FROM library_known_media WHERE NOT adult ORDER BY relevance DESC) SELECT ` + KnownScannerStaticColumns + ` FROM library_known_media INNER JOIN scored ON library_known_media.uid = scored.uid WHERE scored.relevance > {cutoff} ORDER BY scored.relevance DESC`)
}
