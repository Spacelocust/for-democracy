package route

import "github.com/gofiber/fiber/v2"

// SetupRoutes sets up all the routes for the application
func SetupRoutes(app *fiber.App) {
	swaggerRoutes(app)
	rootRoutes(app)
	oauthRoutes(app)
}
