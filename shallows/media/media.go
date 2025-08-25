package media

import (
	"github.com/retrovibed/retrovibed/internal/grpcx"
	"github.com/retrovibed/retrovibed/internal/mimex"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/library"
	"github.com/retrovibed/retrovibed/tracking"
)

type MediaOption func(*Media)

func MediaOptionFromLibraryMetadata(cc library.Metadata) MediaOption {
	return func(c *Media) {
		c.Id = cc.ID
		c.Description = cc.Description
		c.Mimetype = cc.Mimetype
		c.TorrentId = cc.TorrentID
		c.ArchiveId = cc.ArchiveID
		c.KnownMediaId = cc.KnownMediaID
		c.CreatedAt = grpcx.EncodeTime(cc.CreatedAt)
		c.UpdatedAt = grpcx.EncodeTime(cc.UpdatedAt)
		c.Mimetype = stringsx.FirstNonBlank(cc.Mimetype, mimex.Binary)
		c.EncryptionSeed = cc.EncryptionSeed
	}
}

func MediaOptionFromTorrentMetadata(cc tracking.Metadata) MediaOption {
	return func(c *Media) {
		c.Id = cc.ID
		c.TorrentId = cc.ID
		c.Description = cc.Description
		c.KnownMediaId = cc.KnownMediaID
		c.CreatedAt = grpcx.EncodeTime(cc.CreatedAt)
		c.UpdatedAt = grpcx.EncodeTime(cc.UpdatedAt)
		c.Mimetype = stringsx.FirstNonBlank(cc.Mimetype, mimex.Bittorrent)
		c.EncryptionSeed = cc.EncryptionSeed
	}
}
