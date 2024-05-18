package router

import "github.com/gofiber/fiber/v2"

// SetupRoutes sets up all the routes for the application
func SetupRoutes(app *fiber.App) {
	healthRoutes(app)
	swaggerRoutes(app)
	rootRoutes(app)
	oauthRoutes(app)
	planetRoutes(app)
	eventRoutes(app)
}
