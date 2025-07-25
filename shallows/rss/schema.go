package rss

import (
	"encoding/xml"
	"time"

	"github.com/retrovibed/retrovibed/internal/errorsx"
)

// rss represents the shcema of an RSS feed
type rss struct {
	XMLName xml.Name `xml:"rss"`
	Version string   `xml:"version,attr"`
	Channel channel  `xml:"channel"`
}

// in the oficial shcema channel contains more than just `item`
// but there is no need to use those fields
type channel struct {
	XMLName       xml.Name   `xml:"channel"`
	Title         string     `xml:"title"`
	Items         []item     `xml:"item"`
	TTL           int        `xml:"ttl"`
	LastBuildDate xmlTime    `xml:"lastBuildDate"`
	Language      string     `xml:"language"`
	Retrovibed    Retrovibed `xml:"metadata"`
}

// item represent the actual feed for each news
type item struct {
	XMLName     xml.Name    `xml:"item"`
	GUID        string      `xml:"guid"`
	Title       string      `xml:"title"`
	Link        string      `xml:"link"`
	Description string      `xml:"description"`
	PubDate     xmlTime     `xml:"pubDate"`
	Source      *source     `xml:"source"`
	Enclosures  []Enclosure `xml:"enclosure"`
}

func parseTimestamp(encoded string) (_ time.Time, err error) {
	formats := []string{
		time.Layout,
		time.RFC822,
		time.RFC850,
		time.ANSIC,
		time.UnixDate,
		time.RubyDate,
		time.RFC1123,
		time.RFC1123Z,
		time.RFC3339,
		time.RFC3339Nano,
		time.Kitchen,
		time.Stamp,
		time.StampMilli,
		time.StampMicro,
		time.StampNano,
	}

	for _, format := range formats {
		if ts, failed := time.Parse(format, encoded); failed == nil {
			return ts, nil
		} else {
			err = errorsx.Compact(err, failed)
		}
	}

	return time.Time{}, err
}

// this is for custom unmarshaling of date
type xmlTime struct {
	value    time.Time
	hasValue bool
}

func (t xmlTime) Timestamp(fallback time.Time) time.Time {
	if t.hasValue {
		return t.value
	}

	return fallback
}

func (t *xmlTime) UnmarshalXML(d *xml.Decoder, start xml.StartElement) error {
	var encoded string
	d.DecodeElement(&encoded, &start)
	ts, err := parseTimestamp(encoded)
	if err != nil {
		*t = xmlTime{hasValue: false}
		return err
	}
	*t = xmlTime{value: ts, hasValue: true}
	return nil
}

// this represents a cource tag
type source struct {
	XMLName xml.Name `xml:"source"`
	URL     string   `xml:"url,attr"`
	Value   string   `xml:",chardata"`
}

type Channel struct {
	Retrovibed    *Retrovibed
	Title         string
	Link          string
	TTL           int
	LastBuildDate time.Time
	Language      string
	Description   string
	Copyright     string
}

// Item is the representation of an item
// retrieved from an RSS feed
type Item struct {
	Guid        string      // global id
	Title       string      // Defines the title of the item
	Source      *Source     // Specifies a third-party source for the item
	Link        string      // Defines the hyperlink to the item
	PublishDate time.Time   // Defines the last-publication date for the item
	Description string      // Describes the item
	Enclosures  []Enclosure // attached media objects
}

type Source struct {
	XMLName     xml.Name `xml:"source"`
	Description string
	URL         string
}

type Retrovibed struct {
	Entropy  string `xml:"entropy,attr,omitempty"`
	Mimetype string `xml:"mimetype,attr,omitempty"`
}

type Enclosure struct {
	URL      string `xml:"url,attr"`
	Mimetype string `xml:"type,attr"`
	Length   uint64 `xml:"length,attr"`
}
