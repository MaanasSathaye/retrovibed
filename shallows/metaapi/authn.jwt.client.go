package metaapi

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"golang.org/x/oauth2"
)

func AutoJWTClient(ctx context.Context) (c *http.Client, err error) {
	c, err = authn.Oauth2HTTPClient(ctx)
	if err != nil {
		return nil, errorsx.Wrap(err, "failed to create oauth2 http client")
	}

	return JWTClient(c), nil
}

func JWTClient(oauth2c *http.Client) *http.Client {
	return oauth2.NewClient(
		context.WithValue(context.Background(), oauth2.HTTPClient, authn.HTTPClientDefaults()),
		&jwttokensource{
			oauth2c:  oauth2c,
			endpoint: fmt.Sprintf("https://%s", deeppool.Deeppool()),
		},
	)
}

type jwttokensource struct {
	oauth2c  *http.Client
	endpoint string
}

func (t *jwttokensource) Token() (*oauth2.Token, error) {
	var (
		authed Authed
	)

	ctx, done := context.WithTimeout(context.Background(), 3*time.Second)
	defer done()

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, fmt.Sprintf("%s/authn/ssh", t.endpoint), nil)
	if err != nil {
		return nil, err
	}

	resp, err := httpx.AsError(t.oauth2c.Do(req))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if err = json.NewDecoder(resp.Body).Decode(&authed); err != nil {
		return nil, err
	}

	switch len(authed.Profiles) {
	case 0:
		return nil, fmt.Errorf("no profiles associated with this identity. this should have been done automatically during boot")
	case 1:
	default:
		return nil, fmt.Errorf("mumlitple profiles per identity not supported")
	}

	return &oauth2.Token{AccessToken: authed.Profiles[0].Token}, err
}

func AuthzClient(oauth2c *http.Client) *http.Client {
	cc := authn.HTTPClientDefaults()
	return oauth2.NewClient(
		context.WithValue(context.Background(), oauth2.HTTPClient, cc),
		&metatokensource{
			oauth2c:  oauth2c,
			endpoint: fmt.Sprintf("https://%s", deeppool.Deeppool()),
		},
	)
}

type metatokensource struct {
	oauth2c  *http.Client
	endpoint string
}

func (t *metatokensource) Token() (*oauth2.Token, error) {
	var (
		authed AuthzResponse
	)

	ctx, done := context.WithTimeout(context.Background(), 3*time.Second)
	defer done()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, fmt.Sprintf("%s/m/authz/", t.endpoint), nil)
	if err != nil {
		return nil, err
	}

	resp, err := httpx.AsError(t.oauth2c.Do(req))
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if err = json.NewDecoder(resp.Body).Decode(&authed); err != nil {
		return nil, err
	}

	return &oauth2.Token{AccessToken: authed.Bearer}, err
}
