package helldivers

import (
	"fmt"
	"slices"
	"sync"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/enum"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PlanetEvent struct {
	Target         int    `json:"planetIndex"`
	EnemyFaction   int    `json:"race"`
	EnemyHealth    int    `json:"health"`
	EnemyMaxHealth int    `json:"maxHealth"`
	StartAt        string `json:"startTime"`
	EndAt          string `json:"endTime"`
}

type DefencesWar struct {
	PlanetStatus []PlanetStatus `json:"planetStatus"`
	PlanetEvents []PlanetEvent  `json:"planetEvents"`
}

type Defence struct {
	Target         int
	Health         int
	Players        int
	EnemyFaction   int
	EnemyHealth    int
	EnemyMaxHealth int
	StartAt        string
	EndAt          string
}

var errorDefence = err.NewError("[defence]")

func formatDefences(defencesWar *DefencesWar) *[]Defence {
	defences := make([]Defence, 0)

	for _, planet := range defencesWar.PlanetEvents {
		indexPlanet := slices.IndexFunc(defencesWar.PlanetStatus, func(p PlanetStatus) bool {
			return p.Index == planet.Target
		})

		if indexPlanet != -1 {
			defences = append(defences, Defence{
				Target:  planet.Target,
				Health:  defencesWar.PlanetStatus[indexPlanet].Health,
				Players: defencesWar.PlanetStatus[indexPlanet].Players,
			})
		}
	}

	return &defences
}

func storeDefences(merrch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()
	defencesWar, err := fetchWar[DefencesWar]("/WarSeason/801/Status")
	if err != nil {
		merrch <- errorDefence.Error(err, "error getting defencesWar")
		wg.Done()
		return
	}

	defences := formatDefences(&defencesWar)
	newDefences := make([]model.Defence, 0)

	if err := db.Transaction(func(tx *gorm.DB) error {

		if len(*defences) == 0 {
			if err := tx.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&model.Defence{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}
		} else {
			for _, defence := range *defences {
				planet := model.Planet{}

				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", defence.Target).First(&planet).Error; err != nil {
					return errorDefence.Error(err, "error getting planet")
				}

				startDate, err := time.Parse(time.RFC3339, defence.StartAt)
				if err != nil {
					return errorDefence.Error(err, "error parsing start date")
				}

				endDate, err := time.Parse(time.RFC3339, defence.EndAt)
				if err != nil {
					return errorDefence.Error(err, "error parsing end date")
				}

				faction, err := getFaction(defence.EnemyFaction)
				if err != nil {
					return errorDefence.Error(err, "error getting enemy faction")
				}

				newDefences = append(newDefences, model.Defence{
					Health:         defence.Health,
					HelldiversID:   defence.Target,
					Players:        defence.Players,
					StartAt:        startDate,
					EndAt:          endDate,
					EnemyFaction:   faction,
					EnemyHealth:    defence.EnemyHealth,
					EnemyMaxHealth: defence.EnemyMaxHealth,
					PlanetID:       planet.ID,
				})
			}

			// Delete all defences not in the new defences (remove old defences)
			err = tx.Clauses(clause.NotConditions{
				Exprs: []clause.Expression{
					clause.IN{
						Column: clause.Column{Name: "helldivers_id"},
						Values: utils.GetValues(newDefences, "HelldiversID"),
					},
				},
			}).Delete(&model.Defence{}).Error

			if err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}

			// Create or update defences
			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"health", "players", "enemy_health", "enemy_max_health", "start_at", "end_at"}),
			}).Create(&newDefences).Error

			if err != nil {
				return errorDefence.Error(err, "error creating defences")
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

func getFaction(id int) (enum.Faction, error) {
	switch id {
	case 1:
		return enum.Humans, nil
	case 2:
		return enum.Terminids, nil
	case 3:
		return enum.Automatons, nil
	case 4:
		return enum.Illuminates, nil
	default:
		return "", fmt.Errorf("invalid faction ID: %d", id)
	}
}
