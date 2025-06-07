package metaapi

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/internal/httpx"
)

func Register(ctx context.Context) error {
	var (
		authed  Authed
		session Session
	)
	c, err := authn.Oauth2HTTPClient(ctx)
	if err != nil {
		return err
	}

	resp, err := httpx.AsError(c.Post("https://localhost:8081/authn/ssh", "", nil))
	if err != nil {
		return err
	}

	if err = json.NewDecoder(resp.Body).Decode(&authed); err != nil {
		return err
	}

	if len(authed.Profiles) > 0 {
		return nil
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://localhost:8081/authn/signup", nil)
	if err != nil {
		return err
	}
	req.Header.Add("authorization", fmt.Sprintf("bearer %s", authed.SignupToken))

	resp, err = httpx.AsError(c.Do(req))
	if err != nil {
		return err
	}

	if err = json.NewDecoder(resp.Body).Decode(&session); err != nil {
		return err
	}

	return nil
}
