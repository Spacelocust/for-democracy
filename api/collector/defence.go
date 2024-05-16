package collector

import (
	"fmt"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Defence struct {
	Target int `json:"index"`
	Health int `json:"health"`
	Event  struct {
		Ennemy struct {
			Health    int `json:"health"`
			MaxHealth int `json:"maxHealth"`
		}
		StartAt string `json:"startTime"`
		EndAt   string `json:"endTime"`
	} `json:"event"`
}

func GetDefences() error {
	db := db.GetDB()
	parsedDefences, err := helldiversFetch[Defence]("/planet-events")

	if err != nil {
		return fmt.Errorf("error getting defences event: %v", err)
	}

	if len(parsedDefences) < 1 {
		return fmt.Errorf("no defences event found")
	}

	db.Transaction(func(tx *gorm.DB) error {
		for _, defence := range parsedDefences {
			planet := model.Planet{}

			if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", defence.Target).First(&planet).Error; err != nil {
				return fmt.Errorf("error getting planet: %v", err)
			}

			startDate, err := time.Parse(time.RFC3339, defence.Event.StartAt)
			if err != nil {
				return fmt.Errorf("error parsing start date: %v", err)
			}

			endDate, err := time.Parse(time.RFC3339, defence.Event.EndAt)
			if err != nil {
				return fmt.Errorf("error parsing start date: %v", err)
			}

			newDefence := model.Defence{
				Health:          defence.Health,
				EnnemyHealth:    defence.Event.Ennemy.Health,
				EnnemyMaxHealth: defence.Event.Ennemy.MaxHealth,
				StartAt:         startDate,
				EndAt:           endDate,
				HelldiversID:    defence.Target,
				PlanetID:        planet.ID,
			}

			if err := tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"health", "ennemy_health", "ennemy_max_health", "start_at", "end_at"}),
			}).Create(&newDefence).Error; err != nil {
				return fmt.Errorf("error creating defence: %v", err)
			}
		}

		return nil
	})

	return nil
}
