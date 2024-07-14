package helldivers

import (
	"math"
	"slices"
	"sync"
	"time"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/maths"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PlanetEvent struct {
	Target       int `json:"planetIndex"`
	EnemyFaction int `json:"race"`
	Health       int `json:"health"`
	MaxHealth    int `json:"maxHealth"`
	StartAt      int `json:"startTime"`
	EndAt        int `json:"expireTime"`
}
type DefencesWar struct {
	Time         int64          `json:"time"`
	PlanetStatus []PlanetStatus `json:"planetStatus"`
	PlanetEvents []PlanetEvent  `json:"planetEvents"`
}

type WarInfoTime struct {
	EndDate   int64 `json:"endDate"`
	StartDate int64 `json:"startDate"`
}

type Defence struct {
	Target       int
	Players      int
	EnemyFaction int
	Health       int
	MaxHealth    int
	StartAt      int64
	EndAt        int64
}

var errorDefence = err.NewError("[defence]")

func formatDefences(defencesWar *DefencesWar) []Defence {
	defences := make([]Defence, 0)

	for _, planet := range defencesWar.PlanetEvents {
		indexPlanet := slices.IndexFunc(defencesWar.PlanetStatus, func(p PlanetStatus) bool {
			return p.Index == planet.Target
		})

		if indexPlanet != -1 {
			defences = append(defences, Defence{
				Target:       planet.Target,
				Players:      defencesWar.PlanetStatus[indexPlanet].Players,
				EnemyFaction: planet.EnemyFaction,
				Health:       planet.Health,
				MaxHealth:    planet.MaxHealth,
				StartAt:      int64(planet.StartAt),
				EndAt:        int64(planet.EndAt),
			})
		}
	}

	return defences
}

func storeDefences(db *gorm.DB, merrch chan<- error, wg *sync.WaitGroup) {
	warInfoTime, err := fetchWar[WarInfoTime]("/WarSeason/801/WarInfo")
	if err != nil {
		merrch <- errorDefence.Error(err, "error getting warInfoTime")
		wg.Done()
		return
	}

	defencesWar, err := fetchWar[DefencesWar]("/WarSeason/801/Status")
	if err != nil {
		merrch <- errorDefence.Error(err, "error getting defencesWar")
		wg.Done()
		return
	}

	defences := formatDefences(&defencesWar)

	// Get the game time
	gameTime := time.Unix(warInfoTime.StartDate+defencesWar.Time, 0)

	// Get the deviation between the game time and the current time
	gameTimeDeviation := time.Now().UTC().Sub(gameTime)

	// Get the relative game start time
	relativeGameStart := time.Unix(0, 0).Add(gameTimeDeviation).Add(time.Duration(warInfoTime.StartDate) * time.Second)

	if err := db.Transaction(func(tx *gorm.DB) error {

		if len(defences) == 0 {
			if err := tx.Unscoped().Where("updated_at < ?", time.Now()).Delete(&model.Defence{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}
		} else {
			// Delete all defences not in the new defences (remove old defences)
			err = tx.Unscoped().Clauses(clause.NotConditions{
				Exprs: []clause.Expression{
					clause.IN{
						Column: clause.Column{Name: "helldivers_id"},
						Values: utils.GetValues(defences, "Target"),
					},
				},
			}).Delete(&model.Defence{}).Error

			if err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}

			for _, defence := range defences {
				planet := model.Planet{}

				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", defence.Target).First(&planet).Error; err != nil {
					return errorDefence.Error(err, "error getting planet")
				}

				startDate := relativeGameStart.Add(time.Duration(defence.StartAt) * time.Second)
				if err != nil {
					return errorDefence.Error(err, "error parsing start date")
				}

				// Convert unix time to RFC3339
				endDate := relativeGameStart.Add(time.Duration(defence.EndAt) * time.Second)
				if err != nil {
					return errorDefence.Error(err, "error parsing end date")
				}

				faction, err := getFaction(defence.EnemyFaction)
				if err != nil {
					return errorDefence.Error(err, "error getting enemy faction")
				}

				newDefence := model.Defence{
					HelldiversID: defence.Target,
					Players:      defence.Players,
					StartAt:      startDate,
					EndAt:        endDate,
					EnemyFaction: faction,
					Health:       defence.Health,
					MaxHealth:    defence.MaxHealth,
					PlanetID:     planet.ID,
				}

				// Create or update defences
				err = tx.Clauses(clause.OnConflict{
					Columns:   []clause.Column{{Name: "helldivers_id"}},
					DoUpdates: clause.AssignmentColumns([]string{"players", "health", "enemy_faction", "max_health", "start_at", "end_at", "updated_at"}),
				}).Create(&newDefence).Error

				if err != nil {
					return errorDefence.Error(err, "error creating defences")
				}

				newHealthHistory := model.DefenceHealthHistory{
					Health:    newDefence.Health,
					DefenceID: newDefence.ID,
				}

				// Create the defence health history
				if err := tx.Create(&newHealthHistory).Error; err != nil {
					return errorDefence.Error(err, "error creating defence health history")
				}

				previousHealthHistory := model.DefenceHealthHistory{}

				// Get the first health history record before the current one (max 20min earlier)
				result := tx.Where("defence_id = ?", newDefence.ID).Order("created_at asc").Limit(1).Find(&previousHealthHistory)

				if result.Error != nil {
					return errorDefence.Error(result.Error, "error getting previous health history")
				}

				// Calculate the time difference between the two health history records in minutes to calculate the impact per hour
				timeDiff := math.Round(newHealthHistory.CreatedAt.Sub(previousHealthHistory.CreatedAt).Minutes())

				if result.RowsAffected > 0 && timeDiff > 0 {
					// Calculate the health percentage of the previous and new health history

					previousHealthPercentage := (float64(newDefence.MaxHealth-previousHealthHistory.Health) * 100) / float64(newDefence.MaxHealth)
					newHealthPercentage := (float64(newDefence.MaxHealth-newHealthHistory.Health) * 100) / float64(newDefence.MaxHealth)

					// Calculate the impact of the defence health change on the planetary control (*3 due to the 20min interval)
					newDefence.ImpactPerHour = maths.RoundFloat((newHealthPercentage-previousHealthPercentage)*(60/timeDiff), 3)
				}

				// Update the defence impact per hour
				tx.Save(&newDefence)
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
