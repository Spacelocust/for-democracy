package router

import "github.com/gofiber/fiber/v2"

func healthRoutes(app *fiber.App) {
	app.Get("/healthz", func(c *fiber.Ctx) error {
		return c.SendStatus(fiber.StatusOK)
	})
}
