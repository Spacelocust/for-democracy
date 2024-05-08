package gather

import (
	"os"
)

var HELLHUB_API_URL = os.Getenv("HELLHUB_API_URL")

func GatherData() {
	getPlanets()
}
