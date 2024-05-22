package helldivers

import (
	"slices"
	"strconv"
	"sync"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
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
	Target  int
	Health  int
	Players int
}

var errorLiberation = err.NewError("[liberation]")

func formatLiberations(attacksWar *AttacksWar) *[]Liberation {
	Liberations := make([]Liberation, 0)
	state := make(map[string]string)

	for _, planet := range attacksWar.PlanetAttacks {
		index := strconv.Itoa(planet.Target)
		if _, ok := state[index]; !ok {
			state[index] = index

			indexPlanet := slices.IndexFunc(attacksWar.PlanetStatus, func(p PlanetStatus) bool {
				return p.Index == planet.Target
			})

			if indexPlanet != -1 {
				Liberations = append(Liberations, Liberation{
					Target:  planet.Target,
					Health:  attacksWar.PlanetStatus[indexPlanet].Health,
					Players: attacksWar.PlanetStatus[indexPlanet].Players,
				})
			}
		}
	}

	return &Liberations
}

func storeLiberations(merrch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()
	attacksWar, err := fetchWar[AttacksWar]("/WarSeason/801/Status")
	if err != nil {
		merrch <- errorLiberation.Error(err, "error getting attacksWar")
		wg.Done()
		return
	}

	liberations := formatLiberations(&attacksWar)
	newLiberations := make([]model.Liberation, 0)

	if err := db.Transaction(func(tx *gorm.DB) error {

		if len(*liberations) == 0 {
			if err := tx.Session(&gorm.Session{AllowGlobalUpdate: true}).Delete(&model.Liberation{}).Error; err != nil {
				return errorDefence.Error(err, "error deleting defences")
			}
		} else {
			for _, liberation := range *liberations {
				planet := model.Planet{}

				if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.Target).First(&planet).Error; err != nil {
					return errorLiberation.Error(err, "error getting planet")
				}

				newLiberations = append(newLiberations, model.Liberation{
					Health:       liberation.Health,
					HelldiversID: liberation.Target,
					Players:      liberation.Players,
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
				DoUpdates: clause.AssignmentColumns([]string{"health", "players"}),
			}).Create(&newLiberations).Error

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
