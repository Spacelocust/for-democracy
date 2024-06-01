package hellhub

import (
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Effect struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

var errorEffect = err.NewError("[effect]")

// Get all effects from the HellHub API and store them in the database
func storeEffects(db *gorm.DB, effects *[]model.Effect, errpch chan<- error, wg *sync.WaitGroup) {
	parsedEffects, err := fetch[Effect]("/effects")

	if err != nil {
		errpch <- errorEffect.Error(err, "error getting effects")
		wg.Done()
		return
	}

	if len(parsedEffects) < 1 {
		errpch <- errorEffect.Error(nil, "no effects found")
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
		errpch <- errorEffect.Error(err, "error creating effects")
		wg.Done()
		return
	}

	errpch <- nil
	wg.Done()
}
