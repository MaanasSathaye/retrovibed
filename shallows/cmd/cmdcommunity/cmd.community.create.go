package cmdcommunity

import (
	"encoding/json"
	"os"

	"github.com/retrovibed/retrovibed/cmd/cmdopts"
	"github.com/retrovibed/retrovibed/internal/errorsx"
	"github.com/retrovibed/retrovibed/meta"
	"github.com/retrovibed/retrovibed/metaapi"
)

type cmdCommunityCreate struct {
	Name        string `flag:"" name:"name" help:"name of the community globally unique. must be valid url subdomain" required:"true"`
	Description string `flag:"" name:"description" help:"description of the community"`
	Mimetype    string `flag:"" name:"mimetype" help:"mimetype for the community, used to specify the general type that will appear in the feed"`
}

func (t cmdCommunityCreate) Run(gctx *cmdopts.Global) (err error) {
	if err := metaapi.Register(gctx.Context); err != nil {
		return errorsx.Wrap(err, "unable to register with archival service")
	}

	c, err := metaapi.AutoJWTClient(gctx.Context)
	if err != nil {
		return errorsx.Wrap(err, "unable to create api client")
	}

	commresp, err := metaapi.CommunityCreate(gctx.Context, c, &meta.CommunityCreateRequest{Community: &meta.Community{
		Domain:      t.Name,
		Description: t.Description,
		Mimetype:    t.Mimetype,
	}})
	if err != nil {
		return errorsx.Wrap(err, "failed to create community")
	}

	if err = json.NewEncoder(os.Stdout).Encode(commresp.Community); err != nil {
		return errorsx.Wrap(err, "unable to write to encoder")
	}

	return nil
}
