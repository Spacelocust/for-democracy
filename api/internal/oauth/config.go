package oauth

import (
	"fmt"
	"os"

	"github.com/gorilla/sessions"
	"github.com/markbates/goth"
	"github.com/markbates/goth/gothic"
	"github.com/markbates/goth/providers/steam"
)

var baseUrl = os.Getenv("SITE_BASE_URL")

func init() {
	key := "big-key"  // Replace with your SESSION_SECRET or similar
	maxAge := 60 * 60 // 1 hour
	isProd := false   // Set to true when serving over https

	store := sessions.NewCookieStore([]byte(key))
	store.MaxAge(maxAge)
	store.Options.Path = "/"
	store.Options.HttpOnly = true // HttpOnly should always be enabled
	store.Options.Secure = isProd

	gothic.Store = store

	goth.UseProviders(steam.New(os.Getenv("STEAM_KEY"), fmt.Sprintf("%s/oauth/steam/callback", baseUrl)))
}
