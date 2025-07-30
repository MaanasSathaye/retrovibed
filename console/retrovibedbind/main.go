package main

import "C"
import (
	"context"
	"crypto/tls"
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/retrovibed/retrovibed/authn"
	"github.com/retrovibed/retrovibed/cmd/cmdglobalmain"
	"github.com/retrovibed/retrovibed/cmd/cmdmeta"
	"golang.org/x/oauth2"
)

//export oauth2_bearer
func oauth2_bearer() *C.char {
	var (
		err   error
		token *oauth2.Token
	)

	ctx, done := context.WithTimeout(context.Background(), 10*time.Second)
	defer done()

	chttp := &http.Client{
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

	signer, err := authn.SSHSigner()
	if err != nil {
		log.Println("failed to create oauth2 bearer token", err)
		return C.CString("")
	}

	if token, err = authn.Oauth2Bearer(ctx, signer, chttp, "", authn.UserDisplayName()); err != nil {
		log.Println("failed to create oauth2 bearer token", err)
		return C.CString("")
	}

	return C.CString(token.AccessToken)
}

//export authn_bearer
func authn_bearer() *C.char {
	bearer, err := authn.NewBearer()
	if err != nil {
		log.Fatalln(err)
	}
	return C.CString(bearer)
}

//export authn_bearer_host
func authn_bearer_host(hostname *C.char) *C.char {
	ctx, done := context.WithTimeout(context.Background(), 10*time.Second)
	defer done()

	// temporary
	ctransport := &http.Transport{
		TLSClientConfig: &tls.Config{
			InsecureSkipVerify: true,
		},
	}
	defaultclient := &http.Client{Transport: ctransport, Timeout: 20 * time.Second}
	defaultclient = authn.RetryClient(defaultclient)

	bearer, err := authn.BearerForHost(ctx, defaultclient, C.GoString(hostname))
	if err != nil {
		log.Println(err)
		return C.CString("")
	}

	return C.CString(bearer.AccessToken)
}

//export public_key
func public_key() *C.char {
	encoded, err := os.ReadFile(authn.PublicKeyPath())
	if err != nil {
		log.Fatalln(err)
	}

	return C.CString(string(encoded))
}

//export ips
func ips() *C.char {
	ctx, done := context.WithTimeout(context.Background(), 10*time.Second)
	defer done()
	db, err := cmdmeta.Database(ctx)
	if err != nil {
		log.Fatalln(err)
	}
	defer db.Close()

	if err := cmdglobalmain.Profile(db); err != nil {
		log.Fatalln(err)
	}

	results, err := cmdmeta.Hostnames(ctx, db)
	if err != nil {
		log.Fatalln(err)
	}

	encoded, err := json.Marshal(results)
	if err != nil {
		log.Fatalln(err)
	}

	return C.CString(string(encoded))
}

//export egdaemon
func egdaemon(jsonargs *C.char) {
	var args []string
	if err := json.Unmarshal([]byte(C.GoString(jsonargs)), &args); err != nil {
		log.Fatalln(err)
	}

	go cmdglobalmain.Main(args...)
}

func main() {}
