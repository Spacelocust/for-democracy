package router

import "github.com/gofiber/fiber/v3"

// rootRoutes sets up the root route
func rootRoutes(app *fiber.App) {
	app.Get("/", func(c fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})
}
