package router

import "github.com/gofiber/fiber/v2"

// SetupRoutes sets up all the routes for the application
func SetupRoutes(app *fiber.App) {
	rootRoutes(app)
	authRoutes(app)
}
