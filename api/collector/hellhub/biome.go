package hellhub

import (
	"fmt"
	"sync"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm/clause"
)

type Biome struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Get all biomes from the HellHub API and store them in the database
func storeBiomes(biomes *[]model.Biome, respch chan<- error, wg *sync.WaitGroup) {
	start := time.Now()
	db := db.GetDB()
	parsedBiomes, err := hellhubFetch[Biome]("/biomes?limit=20")

	if err != nil {
		respch <- fmt.Errorf("error getting biomes: %v", err)
		wg.Done()
		return
	}

	if len(parsedBiomes) < 1 {
		respch <- fmt.Errorf("error getting biomes: %v", err)
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
		respch <- fmt.Errorf("error creating biomes: %v", err)
		wg.Done()
		return
	}

	respch <- nil
	wg.Done()
	fmt.Println("After done biomes :", time.Since(start))
}
