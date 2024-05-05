package main

import (
	"fmt"
	"os"

	_ "ariga.io/atlas-provider-gorm/gormschema"
	"github.com/Spacelocust/for-democracy/config"
	"github.com/Spacelocust/for-democracy/database"
	"github.com/Spacelocust/for-democracy/docs"
	"github.com/Spacelocust/for-democracy/router/middleware"
	"github.com/Spacelocust/for-democracy/router/route"
	"github.com/bytedance/sonic"
	"github.com/gofiber/fiber/v2"
)

// @BasePath /
// @title For Democracy API
// @version 1.0
// @description This is the API for For Democracy
// @termsOfService http://swagger.io/terms/
// @contact.name Support Team
// @contact.email support@for-democracy
// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html
func main() {
	// Set up the Swagger documentation
	docs.SwaggerInfo.Host = os.Getenv("SITE_BASE_URL")
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

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
}
