package helldivers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/enum"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/bytedance/sonic"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Defence struct {
	Target int `json:"index"`
	Health int `json:"health"`
	Event  struct {
		Ennemy struct {
			Faction   string `json:"faction"`
			Health    int    `json:"health"`
			MaxHealth int    `json:"maxHealth"`
		}
		StartAt string `json:"startTime"`
		EndAt   string `json:"endTime"`
	} `json:"event"`
}

var errorDefence = err.NewError("[defence]")

func fetchDefences[T any](url string) ([]T, error) {
	var data []T

	resp, err := http.Get(fmt.Sprintf("%s%s%s", os.Getenv("HELLDIVERS_API_URL"), "/api/v1", url))
	if err != nil {
		return nil, fmt.Errorf("failed to make HTTP request: %w", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	if err := sonic.Unmarshal(body, &data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return data, nil
}

func storeDefences(merrch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()
	parsedDefences, err := fetchDefences[Defence]("/planet-events")

	if err != nil {
		merrch <- errorDefence.Error(err, "error getting defences")
		wg.Done()
		return
	}

	if err := db.Transaction(func(tx *gorm.DB) error {

		if len(parsedDefences) == 0 {
			if err := tx.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&model.Defence{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}
		}

		for _, defence := range parsedDefences {
			planet := model.Planet{}

			if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", defence.Target).First(&planet).Error; err != nil {
				return errorDefence.Error(err, "error getting planet")
			}

			startDate, err := time.Parse(time.RFC3339, defence.Event.StartAt)
			if err != nil {
				return errorDefence.Error(err, "error parsing start date")
			}

			endDate, err := time.Parse(time.RFC3339, defence.Event.EndAt)
			if err != nil {
				return errorDefence.Error(err, "error parsing end date")
			}

			faction, err := getFaction(defence.Event.Ennemy.Faction)
			if err != nil {
				return errorDefence.Error(err, "error getting ennemy faction")
			}

			newDefence := model.Defence{
				Health:          defence.Health,
				EnnemyFaction:   faction,
				EnnemyHealth:    defence.Event.Ennemy.Health,
				EnnemyMaxHealth: defence.Event.Ennemy.MaxHealth,
				StartAt:         startDate,
				EndAt:           endDate,
				HelldiversID:    defence.Target,
				PlanetID:        planet.ID,
			}

			// Delete all liberations not in the new liberations (remove old liberations)
			err = tx.Clauses(clause.NotConditions{
				Exprs: []clause.Expression{
					clause.IN{
						Column: clause.Column{Name: "helldivers_id"},
						Values: utils.GetValues(parsedDefences, "Target"),
					},
				},
			}).Delete(&model.Defence{}).Error

			if err != nil {
				return errorDefence.Error(err, "error deleting defence")
			}

			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"health", "ennemy_health", "ennemy_max_health", "start_at", "end_at"}),
			}).Create(&newDefence).Error

			if err != nil {
				return errorDefence.Error(err, "error creating defence")
			}
		}

		return nil
	}); err != nil {
		merrch <- err
		wg.Done()
		return
	}

	merrch <- nil
	wg.Done()
}

func getFaction(name string) (enum.Faction, error) {
	switch name {
	case "Humans":
		return enum.Humans, nil
	case "Terminids":
		return enum.Terminids, nil
	case "Automatons":
		return enum.Automatons, nil
	case "Illuminates":
		return enum.Illuminates, nil
	default:
		return "", fmt.Errorf("invalid faction: %s", name)
	}
}
