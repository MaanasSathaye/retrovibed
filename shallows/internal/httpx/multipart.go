package httpx

import (
	"context"
	"fmt"
	"io"
	"mime/multipart"
	"net/textproto"
	"strings"

	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/iox"
)

func escapeQuotes(s string) string {
	quoteEscaper := strings.NewReplacer("\\", "\\\\", `"`, "\\\"")
	return quoteEscaper.Replace(s)
}

func NewMultipartHeader(mimetype string, fieldname string, filename string) textproto.MIMEHeader {
	h := make(textproto.MIMEHeader)
	h.Set("Content-Disposition",
		fmt.Sprintf(`form-data; name="%s"; filename="%s"`,
			escapeQuotes(fieldname), escapeQuotes(filename)))
	h.Set("Content-Type", mimetype)
	return h
}

func Multipart(do func(*multipart.Writer) error) (contentType string, _ io.ReadCloser, err error) {
	r, w := io.Pipe()

	mw := multipart.NewWriter(w)

	ctx, done := context.WithCancelCause(context.Background())
	go func() {
		if err = errorsx.Compact(do(mw), mw.Close()); err != nil {
			w.CloseWithError(err)
		}
		done(nil)
	}()

	return mw.FormDataContentType(), iox.ReaderCompositeCloser(r, func() error {
		return errorsx.Ignore(context.Cause(ctx), context.Canceled)
	}, r.Close), nil
}
