package router

import "github.com/gofiber/fiber/v3"

// SetupRoutes sets up all the routes for the application
func SetupRoutes(app *fiber.App) {
	rootRoutes(app)
	healthzRoutes(app)
}
