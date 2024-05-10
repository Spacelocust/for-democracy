package collector

import "fmt"

type Biome struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getBiomes() (biomes []Biome) {
	biomes, err := getData[Biome]("/biomes?limit=20")

	if err != nil {
		fmt.Println("Error getting biomes")
	}

	return biomes
}
