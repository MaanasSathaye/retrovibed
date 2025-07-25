package jsonl

import (
	"bufio"
	"encoding/json"
	"io"

	"github.com/retrovibed/retrovibed/internal/errorsx"
)

type Encoder struct {
	encoder *json.Encoder // The standard JSON encoder
}

// NewEncoder returns a new Encoder that writes to w.
// The underlying json.Encoder automatically adds a newline after each
// encoded value, making it suitable for JSONL.
func NewEncoder(w io.Writer) *Encoder {
	return &Encoder{
		encoder: json.NewEncoder(w),
	}
}

// Encode writes the JSON encoding of v to the stream, followed by a newline.
// Any error during JSON marshaling or writing to the underlying writer is returned.
func (e *Encoder) Encode(v any) error {
	return e.encoder.Encode(v)
}

// Decoder reads JSON lines from an underlying io.Reader.
// Each call to Decode reads one line, decodes it as a JSON object,
// and stores it in the provided interface.
type Decoder struct {
	scanner *bufio.Scanner // Used to read the input stream line by line
}

// NewDecoder returns a new Decoder that reads from r.
func NewDecoder(r io.Reader) *Decoder {
	return &Decoder{
		scanner: bufio.NewScanner(r),
	}
}

// Decode reads the next JSON line from the stream and stores the result
// in the value pointed to by v.
//
// It returns io.EOF if no more lines are available in the stream.
// It returns an error if scanning a line fails or if the line cannot be
// decoded as a JSON object into v.
func (d *Decoder) Decode(v any) error {
	if !d.scanner.Scan() {
		if err := d.scanner.Err(); err != nil {
			return errorsx.Wrap(err, "failed to scan a line")
		}
		return io.EOF
	}

	line := d.scanner.Bytes()

	// If the line is empty, it's not a valid JSON object.
	// You might choose to skip empty lines or return an error based on strictness.
	// Here, we let json.NewDecoder handle it, which will likely return an error.
	if len(line) == 0 {
		return errorsx.Errorf("encountered empty line, expected JSON object")
	}

	if err := json.Unmarshal(line, v); err != nil {
		return errorsx.Wrapf(err, "unable to decode '%s'", string(line))
	}

	return nil
}
