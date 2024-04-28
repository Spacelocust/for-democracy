package main

import (
	"os"

	_ "ariga.io/atlas-provider-gorm/gormschema"
	"github.com/Spacelocust/for-democracy/cmd"
	"github.com/Spacelocust/for-democracy/docs"
	// _ "github.com/gofiber/fiber/v2"
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
	docs.SwaggerInfo.Host = os.Getenv("SITE_BASE_URL")
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

	cmd.RunCLI()
}
