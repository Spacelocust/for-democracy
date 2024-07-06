package main

import (
	"fmt"
	"os"

	_ "ariga.io/atlas-provider-gorm/gormschema"
	"github.com/Spacelocust/for-democracy/cmd"
	"github.com/Spacelocust/for-democracy/docs"
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
	docs.SwaggerInfo.Host = fmt.Sprintf("%s:%s", os.Getenv("API_DOMAIN"), os.Getenv("API_PORT"))
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

	if os.Getenv("API_ENV") == "production" {
		docs.SwaggerInfo.Host = os.Getenv("API_DOMAIN")
		docs.SwaggerInfo.Schemes = []string{"https"}
	}

	cmd.RunCLI()
}
