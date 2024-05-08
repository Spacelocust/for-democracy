package cmd

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/config"
	"github.com/Spacelocust/for-democracy/database"
	"github.com/Spacelocust/for-democracy/router/middleware"
	"github.com/Spacelocust/for-democracy/router/route"
	"github.com/bytedance/sonic"
	"github.com/gofiber/fiber/v2"
	"github.com/urfave/cli/v2"
)

// ServerCmd is a command to start the server
var serverCmd = &cli.Command{
	Name:    "server",
	Usage:   "Start the server",
	Aliases: []string{"s"},
	Action: func(c *cli.Context) error {
		// Set up the database
		database.ConnectDb()

		// Create a new Fiber app
		app := fiber.New(
			fiber.Config{
				// Replace the default JSON encoder and decoder with Sonic for better performance
				JSONEncoder: sonic.Marshal,
				JSONDecoder: sonic.Unmarshal,
			},
		)

		// Set up the OAuth config
		config.OAuth()

		// Set up the middlewares
		middleware.SetupMiddlewares(app)

		// Set up the routes
		route.SetupRoutes(app)

		if err := app.Listen(":5000"); err != nil {
			fmt.Println(err)
		}
		return nil
	},
}
