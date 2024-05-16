package hellhub

import (
	"fmt"
	"slices"
	"sync"
	"time"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

type Environment struct {
	biomes  *[]model.Biome
	effects *[]model.Effect
}

type Statistic struct {
	MissionsWon        int `json:"missionsWon"`
	MissionTime        int `json:"missionTime"`
	BugKills           int `json:"bugKills"`
	AutomatonKills     int `json:"automatonKills"`
	IlluminateKills    int `json:"illuminateKills"`
	BulletsFired       int `json:"bulletsFired"`
	BulletsHit         int `json:"bulletsHit"`
	TimePlayed         int `json:"timePlayed"`
	Deaths             int `json:"deaths"`
	Revives            int `json:"revives"`
	FriendlyKills      int `json:"friendlyKills"`
	MissionSuccessRate int `json:"missionSuccessRate"`
	Accuracy           int `json:"accuracy"`
}

type Planet struct {
	HelldiversID int       `json:"index"`
	Name         string    `json:"name"`
	Health       int       `json:"health"`
	MaxHealth    int       `json:"maxHealth"`
	Players      int       `json:"players"`
	Disabled     bool      `json:"disabled"`
	Regeneration int       `json:"regeneration"`
	PositionX    float64   `json:"positionX"`
	PositionY    float64   `json:"positionY"`
	ImageURL     string    `json:"imageURL"`
	Statistic    Statistic `json:"statistic"`
	Biome        Biome     `json:"biome"`
	Effects      []Effect  `json:"effects"`
}

func (p *Planet) NewPlanet() *model.Planet {
	return &model.Planet{
		Name:         p.Name,
		Health:       p.Health,
		MaxHealth:    p.MaxHealth,
		Players:      p.Players,
		Disabled:     p.Disabled,
		Regeneration: p.Regeneration,
		PositionX:    p.PositionX,
		PositionY:    p.PositionY,
		HelldiversID: p.HelldiversID,
		ImageURL:     p.ImageURL,
	}
}

func (p *Planet) NewStatistic() *model.Statistic {
	return &model.Statistic{
		HelldiversID:       p.HelldiversID,
		MissionsWon:        p.Statistic.MissionsWon,
		MissionTime:        p.Statistic.MissionTime,
		BugKills:           p.Statistic.BugKills,
		AutomatonKills:     p.Statistic.AutomatonKills,
		IlluminateKills:    p.Statistic.IlluminateKills,
		BulletsFired:       p.Statistic.BulletsFired,
		BulletsHit:         p.Statistic.BulletsHit,
		TimePlayed:         p.Statistic.TimePlayed,
		Deaths:             p.Statistic.Deaths,
		Revives:            p.Statistic.Revives,
		FriendlyKills:      p.Statistic.FriendlyKills,
		MissionSuccessRate: p.Statistic.MissionSuccessRate,
		Accuracy:           p.Statistic.Accuracy,
	}
}

// Store the planets in the database
func persistPlanets(db *gorm.DB, planets []Planet, environnement Environment) error {
	biomes, effects := environnement.biomes, environnement.effects

	err := db.Transaction(func(tx *gorm.DB) error {
		for _, planet := range planets {

			// Create a new model.Planet and model.Statistic
			newPlanet := planet.NewPlanet()
			newStatistic := planet.NewStatistic()

			// Find the index of the current planet's biome in the biomes slice
			planetBiomeIndex := slices.IndexFunc(*biomes, func(biome model.Biome) bool {
				return biome.Name == planet.Biome.Name
			})

			if planetBiomeIndex == -1 {
				return fmt.Errorf("biome %s not found", planet.Biome.Name)
			}

			// Set the new planet's biome and biome ID
			newPlanet.Biome = (*biomes)[planetBiomeIndex]
			newPlanet.BiomeID = (*biomes)[planetBiomeIndex].ID

			// Find the index of the current planet's effects in the effects slice
			planetEffects := make([]model.Effect, len(planet.Effects))
			for i, effect := range planet.Effects {
				planetEffectIndex := slices.IndexFunc(*effects, func(e model.Effect) bool {
					return e.Name == effect.Name
				})

				if planetEffectIndex == -1 {
					return fmt.Errorf("effect %s not found", effect.Name)
				}

				planetEffects[i] = (*effects)[planetEffectIndex]
			}

			// Create the new planet
			err := tx.Omit(clause.Associations).Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "name"}},
				DoUpdates: clause.AssignmentColumns([]string{"health", "max_health", "players", "disabled", "regeneration", "position_x", "position_y", "helldivers_id", "image_url"}),
			}).Create(&newPlanet).Error

			if err != nil {
				return fmt.Errorf("error creating planet: %v", err)
			}

			// Add the foreign key to the statistic
			newStatistic.PlanetID = newPlanet.ID

			// Create the new statistic
			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"mission_time", "bug_kills", "automaton_kills", "illuminate_kills", "bullets_fired", "bullets_hit", "time_played", "deaths", "revives", "friendly_kills", "mission_success_rate", "accuracy"}),
			}).Create(&newStatistic).Error

			if err != nil {
				return fmt.Errorf("error creating statistic: %v", err)
			}

			if err := tx.Omit("Effects.*").Model(&newPlanet).Association("Effects").Append(&planetEffects); err != nil {
				return fmt.Errorf("error adding effects planet: %v", err)
			}

		}

		return nil
	})

	if err != nil {
		return fmt.Errorf("error creating planets: %v", err)
	}

	return nil
}

// Get all planets from the HellHub API and store them in the database
func storePlanets(environment Environment, totalPage int, merrch chan<- error, wg *sync.WaitGroup) {
	db := db.GetDB()

	// Channel to send errors from the goroutines for each page
	errch := make(chan error, totalPage)
	pwg := &sync.WaitGroup{}

	pwg.Add(totalPage)
	for i := range totalPage {
		go func() {
			startTime := time.Now()
			start := i * 100
			planet, err := hellhubFetch[Planet](fmt.Sprintf("/planets?start=%d&limit=100&include[]=statistic&include[]=effects&include[]=biome", start))
			if err != nil {
				errch <- err
				pwg.Done()
				return
			}

			if err := persistPlanets(db, planet, environment); err != nil {
				errch <- err
				pwg.Done()
				return
			}

			// Send nil to the page channel to indicate that the page was successfully fetched
			errch <- nil
			pwg.Done()
			fmt.Println(fmt.Sprintf("Time to get page %d: %s", i, time.Since(startTime)))
		}()
	}

	// Wait for all the goroutines to finish
	pwg.Wait()
	close(errch)

	// Check if there was an error fetching any of the pages
	for err := range errch {
		if err != nil {
			merrch <- err
			wg.Done()
			return
		}
	}

	merrch <- nil
	wg.Done()
}
