package duckdbx

import (
	"github.com/Masterminds/squirrel"
	"github.com/retrovibed/retrovibed/internal/squirrelx"

	"github.com/grindlemire/go-lucene"
	"github.com/grindlemire/go-lucene/pkg/driver"
	"github.com/grindlemire/go-lucene/pkg/lucene/expr"
)

type Lucene struct {
	driver.Base
}

func NewLucene() Lucene {
	fns := map[expr.Operator]driver.RenderFN{
		// expr.Equals: myEquals,
	}

	// iterate over the existing base render functions and swap out any that you want to
	for op, sharedFN := range driver.Shared {
		_, found := fns[op]
		if !found {
			fns[op] = sharedFN
		}
	}

	// return the new driver ready to use
	return Lucene{
		driver.Base{
			RenderFNs: fns,
		},
	}
}

func LuceneQuery(s string) squirrel.Sqlizer {
	return squirrelx.SqlizerFn(func() (sql string, args []interface{}, err error) {
		ast, err := lucene.Parse(s)
		if err != nil {
			return "", nil, err
		}

		return Lucene{}.RenderParam(ast)
	})
}
