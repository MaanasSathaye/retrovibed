package tracking

import (
	"log"
	"unicode"

	"github.com/retrovibed/retrovibed/internal/runesx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"golang.org/x/text/runes"
	"golang.org/x/text/transform"
)

// normalizes the text input. if n error occurs it'll log and return the input unmodified.
func NormalizedDescription(s string) string {
	transformer := transform.Chain(runes.ReplaceIllFormed(), runesx.Replace(unicode.IsPunct, ' '))
	o, _, err := transform.String(transformer, s)
	if err == nil {
		return stringsx.CompactWhitespace(o)
	}

	log.Println("unable to normalize description", err)
	return s
}
