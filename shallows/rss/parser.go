package rss

import (
	"context"
	"encoding/xml"
	"io"
	"log"
	"net/url"

	"github.com/davecgh/go-spew/spew"
)

func Parse(ctx context.Context, r io.Reader) (*channel, []Item, error) {
	return parseData(r, "")
}

func parseData(data io.Reader, originURL string) (*channel, []Item, error) {
	var r rss

	if err := xml.NewDecoder(data).Decode(&r); err != nil {
		return nil, nil, err
	}

	rssItems := make([]Item, 0, len(r.Channel.Items))
	for _, item := range r.Channel.Items {
		if item.Title == "" && item.Link == "" && item.Description == "" {
			log.Println("skipping item", spew.Sdump(item))
			continue
		}

		rssItem := Item{
			Title:       item.Title,
			Description: item.Description,
			Link:        item.Link,
			Enclosures:  item.Enclosures,
		}

		if item.PubDate.hasValue {
			rssItem.PublishDate = item.PubDate.value
		}

		if item.Source != nil {
			rssItem.Source = &Source{
				Description: item.Source.Value,
				URL:         item.Source.URL,
			}
		} else {
			host := extractSource(originURL)
			rssItem.Source = &Source{
				Description: host,
				URL:         originURL,
			}
		}

		rssItems = append(rssItems, rssItem)
	}

	return &r.Channel, rssItems, nil
}

func extractSource(urlRaw string) string {
	u, err := url.Parse(urlRaw)
	if err != nil {
		return ""
	}

	return u.Hostname()
}

func FindEnclosureURLByMimetype(mimetype string, items ...Item) (enc []Enclosure) {
	for _, i := range items {
		for _, i := range i.Enclosures {
			if i.Mimetype != mimetype {
				continue
			}

			enc = append(enc, i)
		}
	}

	return enc
}

func ItemToEnclosure(i Item) Enclosure {
	return Enclosure{
		URL: i.Link,
	}
}
