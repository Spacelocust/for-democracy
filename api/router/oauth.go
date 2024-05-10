package router

import (
	"github.com/Spacelocust/for-democracy/handler"
	"github.com/gofiber/fiber/v2"
)

// oauthRoutes sets up the authentication routes
func oauthRoutes(app *fiber.App) {
	app.Get("/oauth/:provider/callback", handler.OAuthCallback)
	app.Get("/oauth/logout/:provider", handler.OAuthLogout)
	app.Get("/oauth/:provider", handler.OAuth)
	app.Get("/oauth", handler.Auth)
}
