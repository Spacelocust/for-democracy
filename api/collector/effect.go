package collector

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm/clause"
)

type Effect struct {
	Name        string `json:"name"`
	Description string `json:"description"`
}

func getEffects() error {
	db := db.GetDB()
	effects, err := getData[Effect]("/effects")

	if err != nil {
		return fmt.Errorf("error getting effects: %w", err)
	}

	if len(effects) > 0 {
		newEffects := make([]model.Effect, len(effects))

		for i, effect := range effects {
			newEffects[i] = model.Effect{
				Name:        effect.Name,
				Description: effect.Description,
			}
		}

		err = db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoUpdates: clause.AssignmentColumns([]string{"description"}),
		}).Create(&newEffects).Error

		if err != nil {
			return fmt.Errorf("error creating effects: %w", err)
		}
	}

	return nil
}
