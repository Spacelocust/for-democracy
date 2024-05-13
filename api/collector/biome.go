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

// Get all biomes from the HellHub API and store them in the database
func getBiomes(biomes *[]model.Biome) error {
	db := db.GetDB()
	parsedBiomes, err := getData[Biome]("/biomes?limit=20")

	if err != nil {
		return fmt.Errorf("error getting biomes: %v", err)
	}

	if len(parsedBiomes) < 1 {
		return fmt.Errorf("no biomes found")
	}

	*biomes = make([]model.Biome, len(parsedBiomes))

	for i, biome := range parsedBiomes {
		(*biomes)[i] = model.Biome{
			Name:        biome.Name,
			Description: biome.Description,
		}
	}

	err = db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "name"}},
		DoUpdates: clause.AssignmentColumns([]string{"description"}),
	}).Create(&biomes).Error

	if err != nil {
		return fmt.Errorf("error creating biomes: %v", err)
	}

	return nil
}
