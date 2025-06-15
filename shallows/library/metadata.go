package library

import (
	"context"

	"github.com/Masterminds/squirrel"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/internal/bytesx"
	"github.com/retrovibed/retrovibed/internal/duckdbx"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
	"github.com/retrovibed/retrovibed/internal/timex"
)

type MetadataOption = func(*Metadata)

func MetadataOptionDescription(d string) MetadataOption {
	return func(m *Metadata) {
		m.Description = d
	}
}

func MetadataOptionKnownMediaID(d string) MetadataOption {
	return func(m *Metadata) {
		m.KnownMediaID = d
	}
}

func MetadataOptionAutoDescription(d string) MetadataOption {
	return func(m *Metadata) {
		m.AutoDescription = d
	}
}

func MetadataOptionTorrentID(d string) MetadataOption {
	return func(m *Metadata) {
		m.TorrentID = d
	}
}

func MetadataOptionEncryptionSeed(d string) MetadataOption {
	return func(m *Metadata) {
		m.EncryptionSeed = d
	}
}

func MetadataOptionArchivable(b bool) MetadataOption {
	return func(m *Metadata) {
		if b {
			m.ArchiveID = uuid.Max.String()
		}
	}
}

func MetadataOptionBytes(d uint64) MetadataOption {
	return func(m *Metadata) {
		m.Bytes = d
	}
}

func MetadataOptionOffset(d uint64) MetadataOption {
	return func(m *Metadata) {
		m.DiskOffset = d
	}
}

func MetadataOptionMimetype(s string) MetadataOption {
	return func(m *Metadata) {
		m.Mimetype = s
	}
}

func MetadataOptionCompose(options ...func(*Metadata)) MetadataOption {
	return func(m *Metadata) {
		for _, opt := range options {
			opt(m)
		}
	}
}

func MetadataOptionJSONSafeEncode(p *Metadata) {
	p.CreatedAt = timex.RFC3339NanoEncode(p.CreatedAt)
	p.UpdatedAt = timex.RFC3339NanoEncode(p.UpdatedAt)
	p.HiddenAt = timex.RFC3339NanoEncode(p.HiddenAt)
	p.TombstonedAt = timex.RFC3339NanoEncode(p.TombstonedAt)
}

func MetadataOptionTestDefaults(p *Metadata) {
	p.ID = uuid.Nil.String()
	p.ArchiveID = uuid.Nil.String()
	p.TorrentID = uuid.Nil.String()
	p.KnownMediaID = uuid.Nil.String()
	p.EncryptionSeed = uuid.Nil.String()
	p.Bytes = 16 * bytesx.KiB
	p.DiskOffset = 0
}

func NewMetadata(id string, options ...func(*Metadata)) (m Metadata) {
	r := langx.Clone(Metadata{
		ID:             id,
		TorrentID:      uuid.Nil.String(),
		ArchiveID:      uuid.Nil.String(),
		KnownMediaID:   uuid.Nil.String(),
		EncryptionSeed: uuid.Must(uuid.NewV4()).String(),
	}, options...)

	return r
}

func MetadataQueryVisible() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.hidden_at = 'infinity'")
}

func MetadataQueryHidden() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.hidden_at < NOW()")
}

func MetadataQueryArchived() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.archive_id != '00000000-0000-0000-0000-000000000000' AND library_metadata.archive_id != 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'")
}

func MetadataQueryArchivable() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.archive_id = 'FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'")
}

func MetadataQueryShared() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.torrent_id != '00000000-0000-0000-0000-000000000000'")
}

func MetadataQueryNotIndexed() squirrel.Sqlizer {
	return squirrel.Expr("library_metadata.auto_description == ''")
}

func MetadataSearch(ctx context.Context, q sqlx.Queryer, b squirrel.SelectBuilder) MetadataScanner {
	return NewMetadataScannerStatic(b.RunWith(q).QueryContext(ctx))
}

func MetadataQuerySearch(q string, columns ...string) squirrel.Sqlizer {
	return duckdbx.FTSSearch("fts_main_library_metadata", q, columns...)
}

func MetadataSearchBuilder() squirrel.SelectBuilder {
	return squirrelx.PSQL.Select(sqlx.Columns(MetadataScannerStaticColumns)...).From("library_metadata")
}

func MetadataDiskStorageUsage(ctx context.Context, q sqlx.Queryer) sqlx.IntRowScanner {
	return sqlx.NewIntRowScanner(q.QueryRowContext(ctx, "SELECT SUM(bytes) FROM library_metadata"))
}
