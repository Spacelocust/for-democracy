package config

import (
	"fmt"
	"os"
	"time"

	"github.com/gofiber/fiber/v2/middleware/session"
	"github.com/gofiber/storage/postgres/v3"
	"github.com/markbates/goth"
	"github.com/markbates/goth/providers/steam"
	"github.com/shareed2k/goth_fiber"
)

// OAuth sets up the OAuth config and providers
func OAuth() {
	config := session.Config{
		Expiration: 86400 * 30,
		Storage: postgres.New(postgres.Config{
			ConnectionURI: os.Getenv("DB_URL"),
			Table:         "session_storage",
			Reset:         false,
			GCInterval:    10 * time.Second,
		}),
		KeyLookup: "header:session_id",
	}

	// create session handler
	goth_fiber.SessionStore = session.New(config)

	// Register providers
	goth.UseProviders(steam.New(os.Getenv("STEAM_KEY"), fmt.Sprintf("%s/oauth/steam/callback", os.Getenv("SITE_BASE_URL"))))
}
