package collector

import (
	"fmt"
	"strconv"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"github.com/Spacelocust/for-democracy/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Liberation struct {
	Target int `json:"target"`
}

func GetLiberations() error {
	db := db.GetDB()
	// parsedLiberations, err := hellhubFetch[Liberation]("/attacks?include[]=target&limit=50")
	parsedLiberations, err := helldiversFetch[Liberation]("/raw/api/WarSeason/801/Status", false)
	if err != nil {
		return fmt.Errorf("error getting liberations event: %v", err)
	}

	if len(parsedLiberations) < 1 {
		return fmt.Errorf("no liberations event found")
	}

	newLiberations := make([]model.Liberation, 0)

	// State to remove duplicates
	state := make(map[string]string)

	db.Transaction(func(tx *gorm.DB) error {
		// Remove duplicates values
		for _, liberation := range parsedLiberations {
			index := strconv.Itoa(liberation.Target.Index)
			if _, ok := state[index]; !ok {
				state[index] = index
				planet := model.Planet{}

				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.Target.Index).First(&planet).Error; err != nil {
					return fmt.Errorf("error getting planet: %v", err)
				}

				newLiberations = append(newLiberations, model.Liberation{
					Health:       liberation.Target.Health,
					HelldiversID: liberation.Target.Index,
					PlanetID:     planet.ID,
				})
			}
		}

		// Delete all liberations not in the new liberations (remove old liberations)
		if err := tx.Clauses(clause.NotConditions{
			Exprs: []clause.Expression{
				clause.IN{
					Column: clause.Column{Name: "helldivers_id"},
					Values: utils.GetValues(newLiberations, "HelldiversID"),
				},
			},
		}).Delete(&model.Liberation{}).Error; err != nil {
			return err
		}

		// Create or update liberations
		err = tx.Clauses(clause.OnConflict{
			Columns:   []clause.Column{{Name: "helldivers_id"}},
			DoUpdates: clause.AssignmentColumns([]string{"health"}),
		}).Create(&newLiberations).Error

		if err != nil {
			return fmt.Errorf("error creating liberations: %v", err)
		}

		return nil
	})

	return nil
}
