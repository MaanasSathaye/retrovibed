package media

import (
	"github.com/retrovibed/retrovibed/rss"
	"github.com/retrovibed/retrovibed/tracking"
)

func NewTrackingFeedRSSFromFeedRSS(req *rss.FeedUpdateRequest) func(*tracking.RSS) {
	return func(t *tracking.RSS) {
		t.Description = req.Feed.Description
		t.URL = req.Feed.Url
		t.Autodownload = req.Feed.Autodownload
		t.Autoarchive = req.Feed.Autoarchive
		t.Contributing = req.Feed.Contributing
	}
}
