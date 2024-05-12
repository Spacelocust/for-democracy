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

func getEffects() {
	db := db.GetDB()
	effects, err := getData[Effect]("/effects")

	if err != nil {
		fmt.Println("Error getting effects")
	}

	if len(effects) > 0 {
		newEffects := []model.Effect{}

		for _, effect := range effects {
			newEffects = append(newEffects, model.Effect{
				Name:        effect.Name,
				Description: effect.Description,
			})
		}

		db.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "name"}},
			DoUpdates: clause.AssignmentColumns([]string{"description"}),
		}).Create(newEffects)
	}
}
