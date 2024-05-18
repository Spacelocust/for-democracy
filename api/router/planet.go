package router

import (
	"github.com/Spacelocust/for-democracy/handler"
	"github.com/gofiber/fiber/v2"
)

func planetRoutes(app *fiber.App) {
	app.Get("/planets", handler.GetPlanets)
	app.Get("/planets/:id", handler.GetPlanet)
}
