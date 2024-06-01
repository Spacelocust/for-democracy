package hellhub

import (
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Biome struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

var errorBiome = err.NewError("[biome]")

// Get all biomes from the HellHub API and store them in the database
func storeBiomes(db *gorm.DB, biomes *[]model.Biome, errpch chan<- error, wg *sync.WaitGroup) {
	parsedBiomes, err := fetch[Biome]("/biomes?limit=20")

	if err != nil {
		errpch <- errorBiome.Error(err, "error getting biomes")
		wg.Done()
		return
	}

	if len(parsedBiomes) < 1 {
		errpch <- errorBiome.Error(nil, "no biomes found")
		wg.Done()
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
		errpch <- errorBiome.Error(err, "error creating biomes")
		wg.Done()
		return
	}

	errpch <- nil
	wg.Done()
}
