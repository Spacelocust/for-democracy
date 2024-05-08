package middleware

import (
	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/healthcheck"
)

// SetupHealthzMiddleware sets up the healthz middleware
func healthzMiddleware(app *fiber.App) {
	app.Use(healthcheck.New(healthcheck.Config{
		LivenessEndpoint:  "/healthz",
		ReadinessEndpoint: "/readyz",
	}))
}
