package route

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/swagger"
)

// swaggerRoutes sets up the swagger routes
func swaggerRoutes(app *fiber.App) {
	app.Get("/swagger/*", swagger.HandlerDefault)
}
