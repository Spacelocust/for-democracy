package router

import (
	"github.com/gofiber/fiber/v3"
	"github.com/gofiber/fiber/v3/middleware/healthcheck"
)

// healthzRoutes sets up the healthz route
func healthzRoutes(app *fiber.App) {
	app.Get("/healthz", healthcheck.NewHealthChecker())
}
