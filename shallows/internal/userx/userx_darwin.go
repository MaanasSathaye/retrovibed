//go:build darwin

package userx

import (
	"os"
	"path/filepath"

	"github.com/retrovibed/retrovibed/internal/envx"
	"github.com/retrovibed/retrovibed/internal/errorsx"
)

// returns the relative root that should be used for all well known directories.
func DefaultRelRoot() string {
	const DefaultDir = "space.retrovibe.retrovibed"
	return DefaultDir
}

// platform specific config directory resolution
func _configDir(rel ...string) string {
	homedir := errorsx.Must(os.UserHomeDir())
	defaultdir := filepath.Join(homedir, "Library", "Application Support")
	return filepath.Join(envx.String(defaultdir, "XDG_CONFIG_HOME"), filepath.Join(rel...))
}

func _cacheDir(rel ...string) string {
	cachedir := errorsx.Must(os.UserCacheDir())
	return filepath.Join(envx.String(cachedir, "XDG_CACHE_HOME"), filepath.Join(rel...))
}

func _dataDir(rel ...string) string {
	return _configDir(rel...)
}
