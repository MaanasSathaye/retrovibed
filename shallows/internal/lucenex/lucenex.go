package lucenex

import (
	"github.com/Masterminds/squirrel"
	"github.com/grindlemire/go-lucene"
	"github.com/grindlemire/go-lucene/pkg/lucene/expr"
	"github.com/retrovibed/retrovibed/internal/langx"
	"github.com/retrovibed/retrovibed/internal/squirrelx"
)

type Driver interface {
	RenderParam(e *expr.Expression) (s string, params []any, err error)
}

type Option func(*config)

type config struct {
	DefaultField string
}

func WithDefaultField(s string) Option {
	return func(c *config) {
		c.DefaultField = s
	}
}
func Query(d Driver, s string, options ...Option) squirrel.Sqlizer {
	cfg := langx.Clone(config{}, options...)
	return squirrelx.SqlizerFn(func() (sql string, args []interface{}, err error) {
		ast, err := lucene.Parse(s, lucene.WithDefaultField(cfg.DefaultField))
		if err != nil {
			return "", nil, err
		}

		return d.RenderParam(ast)
	})
}
