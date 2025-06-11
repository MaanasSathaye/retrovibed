package library

import (
	"context"
	"io"
	"os"

	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/cryptox"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/sqlx"
	"github.com/retrovibed/retrovibed/internal/uuidx"
)

type Media struct {
	Id         string `protobuf:"bytes,1,opt,name=id,proto3" json:"id,omitempty"`
	AccountId  string `protobuf:"bytes,2,opt,name=account_id,proto3" json:"account_id,omitempty"`
	UploadedBy string `protobuf:"bytes,3,opt,name=uploaded_by,proto3" json:"uploaded_by,omitempty"`
	CreatedAt  string `protobuf:"bytes,4,opt,name=created_at,proto3" json:"created_at,omitempty"`
	UpdatedAt  string `protobuf:"bytes,5,opt,name=updated_at,proto3" json:"updated_at,omitempty"`
	Mimetype   string `protobuf:"bytes,6,opt,name=mimetype,proto3" json:"mimetype,omitempty"`
	Bytes      uint64 `protobuf:"varint,7,opt,name=bytes,proto3" json:"bytes,omitempty"`
	Usage      uint64 `protobuf:"varint,8,opt,name=usage,proto3" json:"usage,omitempty"` // represents the actual storage being charged.
}

type archiver interface {
	Upload(ctx context.Context, mimetype string, r io.Reader) (m *deeppool.Media, _ error)
}

func Archive(ctx context.Context, q sqlx.Queryer, m Metadata, vfs fsx.Virtual, dst archiver) error {
	seed := cryptox.NewChaCha8(uuidx.FirstNonZero(uuid.FromStringOrNil(m.EncryptionSeed), uuid.FromStringOrNil(m.ID)).Bytes())

	iosrc, err := os.Open(vfs.Path(m.ID))
	if err != nil {
		return err
	}
	src, err := cryptox.NewReaderChaCha20(seed, iosrc)
	if err != nil {
		return err
	}

	uploaded, err := dst.Upload(ctx, m.Mimetype, io.LimitReader(src, int64(m.Bytes)))
	if err != nil {
		return err
	}

	return MetadataArchivedByID(ctx, q, m.ID, uploaded.Id, uploaded.Usage).Scan(&m)
}
