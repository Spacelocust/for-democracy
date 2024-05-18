package hellhub

import (
	"sync"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
	"gorm.io/gorm/clause"
)

type Effect struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

var errorEffect = err.NewError("[effect]")

// Get all effects from the HellHub API and store them in the database
func storeEffects(effects *[]model.Effect, respch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()
	parsedEffects, err := fetch[Effect]("/effects")

	if err != nil {
		respch <- errorEffect.Error(err, "error getting effects")
		wg.Done()
		return
	}

	if len(parsedEffects) < 1 {
		respch <- errorEffect.Error(nil, "no effects found")
		wg.Done()
		return
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
		respch <- errorEffect.Error(err, "error creating effects")
		wg.Done()
		return
	}

	respch <- nil
	wg.Done()
}
