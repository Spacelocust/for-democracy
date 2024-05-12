package collector

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm/clause"
)

type Biome struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getBiomes() error {
	db := db.GetDB()
	biomes, err := getData[Biome]("/biomes?limit=20")

	if err != nil {
		return fmt.Errorf("error getting biomes: %v", err)
	}

	if len(biomes) > 0 {
		newBiomes := make([]model.Biome, len(biomes))

		for i, biome := range biomes {
			newBiomes[i] = model.Biome{
				Name:        biome.Name,
				Description: biome.Description,
			}
		}

		err = db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoUpdates: clause.AssignmentColumns([]string{"description"}),
		}).Create(&newBiomes).Error

		if err != nil {
			return fmt.Errorf("error creating biomes: %v", err)
		}
	}

	return nil
}
