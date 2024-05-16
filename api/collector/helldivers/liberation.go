package collector

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"slices"
	"strconv"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/bytedance/sonic"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type PlanetStatus struct {
	Index   int `json:"index"`
	Health  int `json:"health"`
	Players int `json:"players"`
}

type PlanetAttack struct {
	Target int `json:"target"`
}

type War struct {
	PlanetStatus  []PlanetStatus `json:"planetStatus"`
	PlanetAttacks []PlanetAttack `json:"planetAttacks"`
}

type Liberation struct {
	Target  int
	Health  int
	Players int
}

func fetchWar(url string) (War, error) {
	var war War

	resp, err := http.Get(fmt.Sprintf("%s%s%s", os.Getenv("HELLDIVERS_API_URL"), "/raw/api", url))
	if err != nil {
		return War{}, fmt.Errorf("failed to make HTTP request: %w", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return War{}, fmt.Errorf("failed to read response body: %w", err)
	}

	if err := sonic.Unmarshal(body, &war); err != nil {
		return War{}, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return war, nil
}

func formatLiberations(war *War) *[]Liberation {
	Liberations := make([]Liberation, 0)
	state := make(map[string]string)

	for _, planet := range war.PlanetAttacks {
		index := strconv.Itoa(planet.Target)
		if _, ok := state[index]; !ok {
			state[index] = index

			indexPlanet := slices.IndexFunc(war.PlanetStatus, func(p PlanetStatus) bool {
				return p.Index == planet.Target
			})

			if indexPlanet != -1 {
				Liberations = append(Liberations, Liberation{
					Target:  planet.Target,
					Health:  war.PlanetStatus[indexPlanet].Health,
					Players: war.PlanetStatus[indexPlanet].Players,
				})
			}
		}
	}

	return &Liberations
}

func GetLiberations() error {
	db := db.GetDB()
	// parsedLiberations, err := hellhubFetch[Liberation]("/attacks?include[]=target&limit=50")
	war, err := fetchWar("/WarSeason/801/Status")
	if err != nil {
		return fmt.Errorf("error getting liberations event: %v", err)
	}

	liberations := formatLiberations(&war)
	newLiberations := make([]model.Liberation, 0)

	db.Transaction(func(tx *gorm.DB) error {
		for _, liberation := range *liberations {
			planet := model.Planet{}

			if err := tx.Model(&model.Planet{}).Where("helldivers_id = ?", liberation.Target).First(&planet).Error; err != nil {
				return fmt.Errorf("error getting planet: %v", err)
			}

			newLiberations = append(newLiberations, model.Liberation{
				Health:       liberation.Health,
				HelldiversID: liberation.Target,
				PlanetID:     planet.ID,
			})
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
