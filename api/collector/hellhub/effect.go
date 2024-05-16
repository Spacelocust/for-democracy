package hellhub

import (
	"fmt"
	"sync"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm/clause"
)

type Effect struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

// Get all effects from the HellHub API and store them in the database
func storeEffects(effects *[]model.Effect, respch chan<- error, wg *sync.WaitGroup) {
	start := time.Now()
	db := db.GetDB()
	parsedEffects, err := hellhubFetch[Effect]("/effects")

	if err != nil {
		respch <- fmt.Errorf("error getting effects: %w", err)
		wg.Done()
		fmt.Println("After done")
	}

	if len(parsedEffects) < 1 {
		respch <- fmt.Errorf("no effects found: %w", err)
		wg.Done()
	}

	*effects = make([]model.Effect, len(parsedEffects))

	for i, effect := range parsedEffects {
		(*effects)[i] = model.Effect{
			Name:        effect.Name,
			Description: effect.Description,
		}
	}

	err = db.Clauses(clause.OnConflict{
		Columns:   []clause.Column{{Name: "name"}},
		DoUpdates: clause.AssignmentColumns([]string{"description"}),
	}).Create(&effects).Error

	if err != nil {
		respch <- fmt.Errorf("error creating effects: %w", err)
		wg.Done()
	}

	respch <- nil
	wg.Done()
	fmt.Println("Effects :", time.Since(start))
}

// func getEffects(effects *[]model.Effect) error {
// 	db := db.GetDB()
// 	parsedEffects, err := hellhubFetch[Effect]("/effects")

// 	if err != nil {
// 		return fmt.Errorf("error getting effects: %w", err)
// 	}

// 	if len(parsedEffects) < 1 {
// 		return fmt.Errorf("No effects found: %w", err)
// 	}

// 	*effects = make([]model.Effect, len(parsedEffects))

// 	for i, effect := range parsedEffects {
// 		(*effects)[i] = model.Effect{
// 			Name:        effect.Name,
// 			Description: effect.Description,
// 		}
// 	}

// 	err = db.Clauses(clause.OnConflict{
// 		Columns:   []clause.Column{{Name: "name"}},
// 		DoUpdates: clause.AssignmentColumns([]string{"description"}),
// 	}).Create(&effects).Error

// 	if err != nil {
// 		return fmt.Errorf("error creating effects: %w", err)
// 	}

// 	return nil
// }
