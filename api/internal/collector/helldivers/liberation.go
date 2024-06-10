package helldivers

import (
	"math"
	"slices"
	"strconv"
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/maths"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PlanetAttack struct {
	Target int `json:"target"`
}

type AttacksWar struct {
	PlanetStatus  []PlanetStatus `json:"planetStatus"`
	PlanetAttacks []PlanetAttack `json:"planetAttacks"`
	PlanetEvents  []PlanetEvent  `json:"planetEvents"`
}

type Liberation struct {
	Target              int     // The planet ID
	Health              int     // The current health of the planet during the liberation
	RegenerationPerHour float64 // The regeneration of the planet per hour
	Players             int     // The number of players on the planet
}

var errorLiberation = err.NewError("[liberation]")

// formatLiberations formats the data from the API to a more usable format
func formatLiberations(attacksWar *AttacksWar) (liberations []Liberation, owners map[int]int) {
	liberations = make([]Liberation, 0)
	owners = make(map[int]int)
	state := make(map[string]string)

	// loop through all the planet attacks and store the planet ID in the state map to avoid duplicates
	for _, planet := range attacksWar.PlanetAttacks {
		index := strconv.Itoa(planet.Target)
		if _, ok := state[index]; !ok {
			state[index] = index

			// Get the index of the planet in the planet status array
			indexPlanet := slices.IndexFunc(attacksWar.PlanetStatus, func(p PlanetStatus) bool {
				return p.Index == planet.Target
			})

			// Check if the attack is a defence (the api doesn't differentiate between attacks and defences, so we need to check if the planet is in the planet events array to know if it's a defence)
			isDefence := slices.IndexFunc(attacksWar.PlanetEvents, func(p PlanetEvent) bool {
				return p.Target == planet.Target
			})

			// Store the actual owner of the planet by the planet ID
			owners[indexPlanet] = attacksWar.PlanetStatus[indexPlanet].Owner

			// If the planet is in the planet status array, store the liberation
			if indexPlanet != -1 && isDefence == -1 {
				liberations = append(liberations, Liberation{
					Target:  planet.Target,
					Health:  attacksWar.PlanetStatus[indexPlanet].Health,
					Players: attacksWar.PlanetStatus[indexPlanet].Players,
					// Calculate the regeneration per hour of the planet (the API returns the regeneration per second)
					RegenerationPerHour: maths.RoundFloat(((attacksWar.PlanetStatus[indexPlanet].Regeneration*100)/1000000)*3600, 2),
				})
			}
		}
	}

	// return the liberations and the owners of the planets
	return liberations, owners
}

// storeLiberations stores the liberations in the database
func storeLiberations(db *gorm.DB, merrch chan<- error, wg *sync.WaitGroup) {
	// Fetch the data from the API
	attacksWar, err := fetchWar[AttacksWar]("/WarSeason/801/Status")
	if err != nil {
		merrch <- errorLiberation.Error(err, "error getting attacksWar")
		wg.Done()
		return
	}

	// Format the data
	liberations, owners := formatLiberations(&attacksWar)

	// Start a transaction to update the liberations to improve performance
	if err := db.Transaction(func(tx *gorm.DB) error {
		if len(owners) > 0 {
			// Update the owner of the planets (the hellhub API doesn't update the data to often, so we can't rely on it to get the owner of the planets)
			for planetID, owner := range owners {
				// The owner is a faction, so we need to get the faction enum by the number
				if faction, err := getFaction(owner); err == nil {
					if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", planetID).Update("owner", faction).Error; err != nil {
						return errorLiberation.Error(err, "error updating planet owner")
					}
				}
			}
		}

		// If there are no liberations from the API, delete all liberations in the database (remove old liberations)
		if len(liberations) == 0 {
			if err := tx.Unscoped().Delete(&model.Liberation{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting liberations")
			}
		} else {
			// Delete all liberations not in the new liberations (remove old liberations)
			err = tx.Clauses(clause.NotConditions{
				Exprs: []clause.Expression{
					clause.IN{
						Column: clause.Column{Name: "helldivers_id"},
						Values: utils.GetValues(liberations, "Target"),
					},
				},
			}).Delete(&model.Liberation{}).Error

			if err != nil {
				return errorLiberation.Error(err, "error deleting old liberations")
			}

			for _, liberation := range liberations {
				planet := model.Planet{}

				// Get the planet to link to the liberation
				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.Target).First(&planet).Error; err != nil {
					return errorLiberation.Error(err, "error getting planet")
				}

				newLiberation := model.Liberation{
					Health:              liberation.Health,
					HelldiversID:        liberation.Target,
					Players:             liberation.Players,
					RegenerationPerHour: liberation.RegenerationPerHour,
					PlanetID:            planet.ID,
				}

				// Create the liberation
				err = tx.Clauses(clause.OnConflict{
					Columns:   []clause.Column{{Name: "helldivers_id"}},
					DoUpdates: clause.AssignmentColumns([]string{"health", "players", "regeneration_per_hour", "updated_at"}),
				}).Create(&newLiberation).Error

				if err != nil {
					return errorLiberation.Error(err, "error creating liberation")
				}

				newHealthHistory := model.LiberationHealthHistory{
					Health:       liberation.Health,
					LiberationID: newLiberation.ID,
				}

				// Create the liberation health history
				if err := tx.Create(&newHealthHistory).Error; err != nil {
					return errorLiberation.Error(err, "error creating liberation health history")
				}

				previousHealthHistory := model.LiberationHealthHistory{}

				// Get the first health history record before the current one (max 20min earlier)
				result := tx.Where("liberation_id = ?", newLiberation.ID).Order("created_at asc").Limit(1).Find(&previousHealthHistory)

				if result.Error != nil {
					return errorLiberation.Error(result.Error, "error getting previous health history")
				}

				// Calculate the time difference between the two health history records in minutes to calculate the impact per hour
				timeDiff := math.Round(newHealthHistory.CreatedAt.Sub(previousHealthHistory.CreatedAt).Minutes())

				if result.RowsAffected > 0 && timeDiff > 0 {
					// Calculate the impact of the liberation health change on the planetary control (*3 due to the 20min interval)
					newLiberation.ImpactPerHour = maths.RoundFloat((newHealthHistory.GetHealthToPercentage()-previousHealthHistory.GetHealthToPercentage())*(60/timeDiff), 3)
				}

				// Update the liberation impact per hour
				tx.Save(&newLiberation)
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
