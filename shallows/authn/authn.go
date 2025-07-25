package authn

import (
	"context"
	"crypto/rand"
	"crypto/tls"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/davecgh/go-spew/spew"
	"github.com/gofrs/uuid/v5"
	"github.com/retrovibed/retrovibed/deeppool"
	"github.com/retrovibed/retrovibed/internal/debugx"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/httpx"
	"github.com/retrovibed/retrovibed/internal/jwtx"
	"github.com/retrovibed/retrovibed/internal/oauth2x"
	"github.com/retrovibed/retrovibed/internal/sshx"
	"github.com/retrovibed/retrovibed/internal/stringsx"
	"github.com/retrovibed/retrovibed/internal/userx"
	"golang.org/x/crypto/ssh"
	"golang.org/x/oauth2"
)

func DeeppoolEndpoint() oauth2.Endpoint {
	return EndpointSSHAuth(fmt.Sprintf("https://%s", deeppool.Deeppool()))
}

func HTTPClientDefaults() *http.Client {
	return &http.Client{
		Transport: &http.Transport{
			Proxy:                 http.ProxyFromEnvironment,
			ForceAttemptHTTP2:     true,
			MaxIdleConns:          100,
			IdleConnTimeout:       90 * time.Second,
			TLSHandshakeTimeout:   10 * time.Second,
			ExpectContinueTimeout: 1 * time.Second,
			TLSClientConfig:       &tls.Config{InsecureSkipVerify: true},
		},
	}
}

func oauth2SSHConfig(signer ssh.Signer, otp string, endpoint oauth2.Endpoint) oauth2.Config {
	return oauth2.Config{
		ClientID:     ssh.FingerprintSHA256(signer.PublicKey()),
		ClientSecret: otp,
		Endpoint:     endpoint,
	}
}

func PublicKeyPath() string {
	return env.PrivateKeyPath() + ".pub"
}

func UserDisplayName() string {
	u := userx.CurrentUserOrDefault(userx.Zero())
	return stringsx.FirstNonBlank(u.Name, u.Username)
}

func Oauth2HTTPClient(ctx context.Context) (*http.Client, error) {
	signer, err := sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath())
	if err != nil {
		return nil, errorsx.Wrap(err, "unable to read identity")
	}

	cfg := oauth2SSHConfig(signer, "", DeeppoolEndpoint())

	c := HTTPClientDefaults()

	token, err := oauth2Bearer(ctx, signer, c, cfg, "", "")
	if err != nil {
		return nil, err
	}

	return cfg.Client(context.WithValue(ctx, oauth2.HTTPClient, c), token), nil
}

func SSHSigner() (ssh.Signer, error) {
	return sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath())
}

func oauth2Bearer(ctx context.Context, signer ssh.Signer, c *http.Client, cfg oauth2.Config, email, displayname string) (*oauth2.Token, error) {
	type exstate struct {
		Entropy   string `json:"uid"`
		PublicKey []byte `json:"pkey"`
		Email     string `json:"email"`
		Display   string `json:"display"`
	}

	c = httpx.BindRetryTransport(c, http.StatusBadGateway, http.StatusTooManyRequests)

	state, err := jwtx.EncodeJSON(exstate{
		Entropy:   errorsx.Must(uuid.NewV4()).String(),
		PublicKey: signer.PublicKey().Marshal(),
		Email:     email,
		Display:   displayname,
	})
	if err != nil {
		return nil, err
	}

	authzuri := cfg.AuthCodeURL(
		state,
		oauth2.AccessTypeOffline,
	)

	exchanged, err := oauth2x.RetrieveAuthCode(ctx, c, authzuri)
	if err != nil {
		return nil, err
	}

	if exchanged.State != state {
		return nil, fmt.Errorf("unexpected state")
	}

	ctx = context.WithValue(ctx, oauth2.HTTPClient, c)
	token, err := cfg.Exchange(ctx, exchanged.Code, oauth2.AccessTypeOffline)

	return token, errorsx.Wrap(err, "token signature failure")
}

func Oauth2Bearer(ctx context.Context, signer ssh.Signer, c *http.Client, email, displayname string) (*oauth2.Token, error) {
	return oauth2Bearer(ctx, signer, c, oauth2SSHConfig(signer, "", DeeppoolEndpoint()), email, displayname)
}

type FnTokenSource func() (*oauth2.Token, error)

func (t FnTokenSource) Token() (*oauth2.Token, error) {
	return t()
}

func AutomaticTokenSource() (*oauth2.Token, error) {
	signer, err := sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath())
	if err != nil {
		return nil, errorsx.Wrap(err, "unable to read identity")
	}

	id := ssh.FingerprintSHA256(signer.PublicKey())

	claims := jwtx.NewJWTClaims(
		id,
		jwtx.ClaimsOptionAuthnExpiration(),
		jwtx.ClaimsOptionIssuer(id),
	)

	debugx.Println("claims", spew.Sdump(claims))

	bearer, err := jwtx.Signed(JWTSecretFromEnv(), claims)
	if err != nil {
		return nil, errorsx.Wrap(err, "unable to create bearer")
	}

	return &oauth2.Token{
		TokenType:   "bearer",
		AccessToken: bearer,
		Expiry:      claims.ExpiresAt.Time,
	}, nil
}

func NewBearer() (string, error) {
	signer, err := sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath())
	if err != nil {
		return "", errorsx.Wrap(err, "unable to read identity")
	}

	id := ssh.FingerprintSHA256(signer.PublicKey())

	claims := jwtx.NewJWTClaims(
		id,
		jwtx.ClaimsOptionAuthnExpiration(),
		jwtx.ClaimsOptionIssuer(id),
	)

	debugx.Println("claims", spew.Sdump(claims))

	bearer, err := jwtx.Signed(JWTSecretFromEnv(), claims)

	return bearer, errorsx.Wrap(err, "token signature failure")
}

func BearerForHost(ctx context.Context, c *http.Client, host string) (string, error) {
	signer, err := sshx.AutoCached(sshx.NewKeyGen(), env.PrivateKeyPath())
	if err != nil {
		return "", errorsx.Wrap(err, "unable to read identity")
	}

	state, err := AutoTokenState(signer)
	if err != nil {
		return "", errorsx.Wrap(err, "unable to generate authentication state")
	}

	ctx = context.WithValue(ctx, oauth2.HTTPClient, c)

	endpoint := EndpointSSHAuth(host)

	cfg := OAuth2SSHConfig(signer, "", endpoint)

	authzuri := cfg.AuthCodeURL(
		state,
		oauth2.AccessTypeOffline,
	)

	r, err := RetrieveAuthCode(ctx, c, authzuri)
	if err != nil {
		return "", errorsx.Wrap(err, "unable to retrieve auth code")
	}
	if r.State != state {
		return "", errorsx.Wrap(err, "invalid state")
	}

	token, err := cfg.Exchange(ctx, r.Code, oauth2.AccessTypeOffline)
	if err != nil {
		return "", errorsx.Wrap(err, "unable to exchange auth code")
	}

	return token.AccessToken, nil
}

func JWTSecretFromEnv() []byte {
	return env.JWTSecret()
}

// Bearer extracts the jwt bearer token from a http request.
func Bearer(req *http.Request) string {
	before, after, _ := strings.Cut(req.Header.Get("authorization"), " ")

	if strings.ToLower(before) != "bearer" {
		return ""
	}

	return after
}

func EndpointSSHAuth(hostname string) oauth2.Endpoint {
	return oauth2.Endpoint{
		AuthURL:   fmt.Sprintf("%s/oauth2/ssh/auth", hostname),
		TokenURL:  fmt.Sprintf("%s/oauth2/ssh/token", hostname),
		AuthStyle: oauth2.AuthStyleInHeader,
	}
}

func OAuth2SSHConfig(signer ssh.Signer, otp string, endpoint oauth2.Endpoint) oauth2.Config {
	return oauth2.Config{
		ClientID:     ssh.FingerprintSHA256(signer.PublicKey()),
		ClientSecret: otp,
		Endpoint:     endpoint,
	}
}

func OAuth2SSHToken(ctx context.Context, signer ssh.Signer, endpoint oauth2.Endpoint) (cfg oauth2.Config, tok *oauth2.Token, err error) {
	var (
		sig *ssh.Signature
	)

	password := uuid.Must(uuid.NewV4())

	cfg = OAuth2SSHConfig(signer, password.String(), endpoint)
	if sig, err = signer.Sign(rand.Reader, password.Bytes()); err != nil {
		return cfg, nil, err
	}

	encodedsig := base64.RawURLEncoding.EncodeToString(ssh.Marshal(sig))

	tok, err = cfg.PasswordCredentialsToken(ctx, cfg.ClientID, encodedsig)
	return cfg, tok, err
}

func AutoTokenState(signer ssh.Signer) (encoded string, err error) {
	type reqstate struct {
		ID        string `json:"id"`
		PublicKey []byte `json:"pkey"`
	}

	id, err := uuid.NewV4()
	if err != nil {
		return "", err
	}
	rawstate := reqstate{
		ID:        id.String(),
		PublicKey: signer.PublicKey().Marshal(),
	}

	if encoded, err = jwtx.EncodeJSON(rawstate); err != nil {
		return "", errorsx.Wrap(err, "unable to encode state")
	}

	return encoded, nil
}

func AutoLocalOauth2Client(ctx context.Context) (c *http.Client) {
	return oauth2.NewClient(context.WithValue(ctx, oauth2.HTTPClient, HTTPClientDefaults()), FnTokenSource(AutomaticTokenSource))
}

type AuthResponse struct {
	Code  string `json:"code"`
	State string `json:"state"`
}

func RetrieveAuthCode(ctx context.Context, chttp *http.Client, uri string) (r AuthResponse, err error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, uri, nil)
	if err != nil {
		return r, err
	}

	resp, err := httpx.AsError(chttp.Do(req))
	if err != nil {
		return r, err
	}
	defer httpx.AutoClose(resp)

	if err = json.NewDecoder(resp.Body).Decode(&r); err != nil {
		return r, err
	}

	return r, nil
}
