package collector

import (
	"fmt"
)

type Effect struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getEffects() (effects []Effect) {
	effects, err := getData[Effect]("/effects")

	if err != nil {
		fmt.Println("Error getting effects")
	}

	return effects
}
