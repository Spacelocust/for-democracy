package server

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/config"
	"github.com/Spacelocust/for-democracy/database"
	"github.com/Spacelocust/for-democracy/middleware"
	"github.com/Spacelocust/for-democracy/router"
	"github.com/gofiber/fiber/v2"
	"github.com/urfave/cli/v2"
)

// ServerCmd starts the API server
func startServer() {
	// Connect to the database
	database.ConnectDb()

	config.StoreSession()
	config.OAuthProviders()

	// Create a new Fiber app
	app := fiber.New()

	// Set up the middlewares
	middleware.SetupMiddlewares(app)

	// Set up the routes
	router.SetupRoutes(app)

	// data, _ := json.MarshalIndent(app.Stack(), "", "  ")
	// fmt.Println(string(data))

	if err := app.Listen(":5000"); err != nil {
		fmt.Println(err)
	}
}

// StartCmd is the CLI command for starting the API server
var StartCmd = &cli.Command{
	Name:    "server",
	Usage:   "Start the API server",
	Aliases: []string{"s"},
	Action: func(c *cli.Context) error {
		startServer()
		return nil
	},
}
