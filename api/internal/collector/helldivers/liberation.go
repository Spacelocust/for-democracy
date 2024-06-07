package helldivers

import (
	"fmt"
	"slices"
	"strconv"
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/math"
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
}

type Liberation struct {
	Target       int
	Health       int
	Regeneration float64
	Players      int
}

var errorLiberation = err.NewError("[liberation]")

func formatLiberations(attacksWar *AttacksWar) (liberations []Liberation, owners map[int]int) {
	liberations = make([]Liberation, 0)
	owners = make(map[int]int)
	state := make(map[string]string)

	for _, planet := range attacksWar.PlanetAttacks {
		index := strconv.Itoa(planet.Target)
		if _, ok := state[index]; !ok {
			state[index] = index

			indexPlanet := slices.IndexFunc(attacksWar.PlanetStatus, func(p PlanetStatus) bool {
				return p.Index == planet.Target
			})

			// Store the actual owner of the planet
			owners[indexPlanet] = attacksWar.PlanetStatus[indexPlanet].Owner

			if indexPlanet != -1 {
				liberations = append(liberations, Liberation{
					Target:       planet.Target,
					Health:       attacksWar.PlanetStatus[indexPlanet].Health,
					Players:      attacksWar.PlanetStatus[indexPlanet].Players,
					Regeneration: attacksWar.PlanetStatus[indexPlanet].Regeneration,
				})
			}
		}
	}

	return liberations, owners
}

func storeLiberations(db *gorm.DB, merrch chan<- error, wg *sync.WaitGroup) {
	attacksWar, err := fetchWar[AttacksWar]("/WarSeason/801/Status")
	if err != nil {
		merrch <- errorLiberation.Error(err, "error getting attacksWar")
		wg.Done()
		return
	}

	liberations, owners := formatLiberations(&attacksWar)
	newLiberations := make([]model.Liberation, 0)

	if err := db.Transaction(func(tx *gorm.DB) error {

		if len(owners) > 0 {
			// Update the owner of the planets (the hellhub API doesn't update the data to often, so we can't rely on it to get the owner of the planets)
			for planetID, owner := range owners {
				if faction, err := getFaction(owner); err == nil {
					if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", planetID).Update("owner", faction).Error; err != nil {
						return errorLiberation.Error(err, "error updating planet owner")
					}
				}
			}
		}

		if len(liberations) == 0 {
			if err := tx.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&model.Liberation{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}
		} else {
			for _, liberation := range liberations {
				planet := model.Planet{}

				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.Target).First(&planet).Error; err != nil {
					return errorLiberation.Error(err, "error getting planet")
				}

				newLiberations = append(newLiberations, model.Liberation{
					Health:       liberation.Health,
					HelldiversID: liberation.Target,
					Players:      liberation.Players,
					Regeneration: liberation.Regeneration,
					PlanetID:     planet.ID,
				})
			}

			// Delete all liberations not in the new liberations (remove old liberations)
			err = tx.Clauses(clause.NotConditions{
				Exprs: []clause.Expression{
					clause.IN{
						Column: clause.Column{Name: "helldivers_id"},
						Values: utils.GetValues(newLiberations, "HelldiversID"),
					},
				},
			}).Delete(&model.Liberation{}).Error

			if err != nil {
				return errorLiberation.Error(err, "error deleting liberations")
			}

			// Create or update liberations
			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"health", "players", "regeneration", "updated_at"}),
			}).Create(&newLiberations).Error

			liberationHealthHistories := []int{}

			for _, liberation := range newLiberations {
				planet := model.Planet{}
				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.HelldiversID).First(&planet).Error; err != nil {
					return errorLiberation.Error(err, "error getting planet")
				}

				fmt.Println("Planet: ", planet.Name)

				tx.Model(model.LiberationHealthHistory{}).Where("liberation_id = ?", liberation.ID).Order("created_at asc").Limit(20).Pluck("health", &liberationHealthHistories)

				lib := []float64{}
				for _, l := range liberationHealthHistories {
					lib = append(lib, float64((1000000-l)*100)/1000000)
				}

				if liberation.ID == 3 {
					fmt.Println("current health: ", liberationHealthHistories[len(liberationHealthHistories)-1])
					fmt.Println("previous health: ", liberationHealthHistories[len(liberationHealthHistories)-2])
					math.Impact(lib, ((liberation.Regeneration*100)/1000000)*3600)
				}
			}

			if err != nil {
				return errorLiberation.Error(err, "error creating liberations")
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
