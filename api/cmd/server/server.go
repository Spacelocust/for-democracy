package server

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/database"
	"github.com/Spacelocust/for-democracy/router"
	"github.com/gofiber/fiber/v3"
	"github.com/urfave/cli/v2"
)

type Config struct {
	Host string
}

// ServerCmd starts the API server
func startServer(config Config) {
	// Connect to the database
	database.ConnectDb()

	// Create a new Fiber app
	app := fiber.New()

	// Set up the routes
	router.SetupRoutes(app)

	if err := app.Listen(config.Host); err != nil {
		fmt.Println(err)
	}
}

// StartCmd is the CLI command for starting the API server
var StartCmd = &cli.Command{
	Name:    "server",
	Usage:   "Start the API server",
	Aliases: []string{"s"},
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "host",
			Value: ":5000",
			Usage: "Host to run the server on",
		},
	},
	Action: func(c *cli.Context) error {
		config := Config{
			Host: c.String("host"),
		}

		startServer(config)
		return nil
	},
}
