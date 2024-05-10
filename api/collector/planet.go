package collector

import (
	"fmt"
)

type Planet struct {
}

func getPlanets() (planets []Planet) {
	planets, err := getData[Planet]("/planets")

	if err != nil {
		fmt.Println("Error getting planets")
	}

	return planets
}
