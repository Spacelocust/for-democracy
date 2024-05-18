package router

import (
	"github.com/Spacelocust/for-democracy/handler"
	"github.com/gofiber/fiber/v2"
)

func eventRoutes(app *fiber.App) {
	app.Get("/events", handler.GetEvents)
}
