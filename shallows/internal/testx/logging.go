package testx

import (
	"flag"
	"io"
	"log"
	"os"
	"testing"

	"github.com/mattn/go-isatty"
)

// Logging enable logging if stdout terminal is a tty.
// generally this means run the ginkgo without the -p (parallel) option.
func Logging() {
	flag.Parse()
	log.SetFlags(log.Lshortfile | log.Ldate | log.LUTC)
	log.SetOutput(os.Stderr)

	if isatty.IsTerminal(os.Stdout.Fd()) || testing.Verbose() {
		return
	}

	log.SetOutput(io.Discard)
}
