package middleware

import "github.com/gofiber/fiber/v2"

// SetupMiddlewares sets up all the middlewares for the application
func SetupMiddlewares(app *fiber.App) {
	healthzMiddleware(app)
}
