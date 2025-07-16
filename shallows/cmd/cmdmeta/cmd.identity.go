package cmdmeta

import (
	"encoding/base64"
	"fmt"
	"io"
	"os"
	"strings"

	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/env"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/internal/fsx"
	"github.com/retrovibed/retrovibed/internal/md5x"
	"github.com/retrovibed/retrovibed/internal/sshx"
	"golang.org/x/crypto/ssh"
)

func printIdentity(w io.Writer, s ssh.Signer) error {
	_, err2 := fmt.Fprintln(w, "fingerprint", ssh.FingerprintSHA256(s.PublicKey()))
	_, err1 := fmt.Fprintln(w, "identity   ", md5x.String(ssh.FingerprintSHA256(s.PublicKey())))
	_, err3 := fmt.Fprintln(w, "public     ", strings.TrimSpace(string(ssh.MarshalAuthorizedKey(s.PublicKey()))))
	_, err4 := fmt.Fprintln(w, "base64     ", base64.URLEncoding.EncodeToString(s.PublicKey().Marshal()))
	return errorsx.Compact(err1, err2, err3, err4)
}

type Identity struct {
	Generate  GenerateID  `cmd:"" help:"bootstrap the identity of the device itself, allows you to provide a seed for consistent generation"`
	Bootstrap Bootstrap   `cmd:"" help:"bootstrap authorized users into the system, used to initially provision the system"`
	Show      IdenDisplay `cmd:"" help:"display current identity"`
}

type IdenDisplay struct{}

func (t IdenDisplay) Run(gctx *cmdopts.Global, id *cmdopts.SSHID) (err error) {
	signer, err := id.Signer()
	if err != nil {
		return err
	}
	return printIdentity(os.Stdout, signer)
}

type GenerateID struct {
	Force bool   `flag:"" name:"force" help:"force creation if a identity already exists, this is to prevent you from accidently destroying your identity"`
	Seed  string `arg:"" name:"seed" help:"used to seed the key generation, this command is used for when you want to maintain a persistent account identity easily" required:"true"`
}

func (t GenerateID) Run(gctx *cmdopts.Global) (err error) {
	if fsx.Exists(env.PrivateKeyPath()) && !t.Force {
		return errorsx.Errorf("an identity already exists at %s, use --force to overwrite, but maybe you should back it up first", env.PrivateKeyPath())
	}

	if err := os.Remove(env.PrivateKeyPath()); err != nil {
		return errorsx.Wrap(err, "unable to remove old key")
	}

	id, err := sshx.AutoCached(sshx.NewKeyGenSeeded(t.Seed), env.PrivateKeyPath())
	if err != nil {
		return err
	}

	return printIdentity(os.Stdout, id)
}
