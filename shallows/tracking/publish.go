package tracking

import (
	"bytes"
	"context"
	"io"
	"log"
	"mime/multipart"
	"os"

	"github.com/james-lawrence/torrent"
	"github.com/james-lawrence/torrent/metainfo"
	"github.com/james-lawrence/torrent/storage"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/mimex"
)

// PublishRequest a torrent to an http endpoint in its entirety
func PublishRequest(ctx context.Context, path string) (boundary string, _ io.ReadCloser, err error) {
	md, err := torrent.NewFromFile(path, torrent.OptionStorage(storage.NewFile(os.TempDir())))
	if err != nil {
		return "", nil, errorsx.Wrapf(err, "unable to create torrent from: %s", path)
	}

	encoded, err := metainfo.Encode(md.Metainfo())
	if err != nil {
		return "", nil, errorsx.Wrap(err, "unable to encode torrent file")
	}

	info, err := md.Metainfo().UnmarshalInfo()
	if err != nil {
		return "", nil, errorsx.Wrap(err, "unable to decode torrent info")
	}

	disk, err := md.Storage.OpenTorrent(&info, md.ID)
	if err != nil {
		return "", nil, errorsx.Wrap(err, "unable to open torrent reader")
	}

	return httpx.Multipart(func(w *multipart.Writer) (merr error) {
		defer log.Println("MULTIPART CREATE DONE")
		defer func() {
			log.Println("DERP DERP", merr)
		}()

		part, lerr := w.CreatePart(httpx.NewMultipartHeader(mimex.Bittorrent, "torrentfile", md.DisplayName))
		if lerr != nil {
			return errorsx.Wrap(lerr, "unable to create torrent file part")
		}

		if _, lerr = io.Copy(part, bytes.NewBuffer(encoded)); lerr != nil {
			return errorsx.Wrap(lerr, "unable to copy archive")
		}

		content, lerr := w.CreatePart(httpx.NewMultipartHeader(mimex.Binary, "contents", ""))
		if lerr != nil {
			return errorsx.Wrap(lerr, "unable to create torrent file part")
		}

		if n, lerr := io.Copy(content, io.NewSectionReader(disk, 0, info.TotalLength())); lerr != nil {
			return errorsx.Wrap(lerr, "unable to copy torrent")
		} else {
			log.Println("copied", n)
		}

		return nil
	})
}
