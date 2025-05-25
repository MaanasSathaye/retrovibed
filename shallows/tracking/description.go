package tracking

import (
	"log"
	"regexp"
	"unicode"

	"github.com/retrovibed/retrovibed/internal/runesx"
	"golang.org/x/text/runes"
	"golang.org/x/text/transform"
)

// replace repeated whitespace with a single space.
var whitespace = regexp.MustCompile(`\s+`)

// normalizes the text input. if n error occurs it'll log and return the input unmodified.
func NormalizedDescription(s string) string {
	transformer := transform.Chain(runes.ReplaceIllFormed(), runesx.Replace(unicode.IsPunct, ' '))
	o, _, err := transform.String(transformer, s)
	if err == nil {
		return whitespace.ReplaceAllString(o, " ")
	}

	log.Println("unable to normalize description", err)
	return s
}
