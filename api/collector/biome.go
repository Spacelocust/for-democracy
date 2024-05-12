package collector

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
)

type Biome struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getBiomes() {
	db := db.GetDB()
	biomes, err := getData[Biome]("/biomes?limit=20")

	if err != nil {
		fmt.Println("Error getting biomes")
	}

	if len(biomes) > 0 {
		newBiomes := []model.Biome{}

		for _, biome := range biomes {
			newBiomes = append(newBiomes, model.Biome{
				Name:        biome.Name,
				Description: biome.Description,
			})
		}

		db.Create(newBiomes)
	}

}
