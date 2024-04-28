package router

import (
	"github.com/Spacelocust/for-democracy/controller"
	"github.com/gofiber/fiber/v2"
)

// oauthRoutes sets up the authentication routes
func oauthRoutes(app *fiber.App) {
	app.Get("/oauth/:provider/callback", controller.OAuthCallback)
	app.Get("/oauth/logout/:provider", controller.OAuthLogout)
	app.Get("/oauth/:provider", controller.OAuth)
	app.Get("/oauth", controller.Auth)
}
