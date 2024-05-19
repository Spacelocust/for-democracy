package hellhub

import (
	"fmt"
	"slices"
	"sync"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/enum"
	"github.com/Spacelocust/for-democracy/db/model"
	err "github.com/Spacelocust/for-democracy/error"
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

type Sector struct {
	HelldiversID int    `json:"index"`
	Name         string `json:"name"`
}

type Planet struct {
	HelldiversID int       `json:"index"`
	Name         string    `json:"name"`
	MaxHealth    int       `json:"maxHealth"`
	Disabled     bool      `json:"disabled"`
	Regeneration int       `json:"regeneration"`
	PositionX    float64   `json:"positionX"`
	PositionY    float64   `json:"positionY"`
	ImageURL     string    `json:"imageURL"`
	Owner        int       `json:"ownerId"`
	InitialOwner int       `json:"initialOwnerId"`
	Statistic    Statistic `json:"statistic"`
	Biome        Biome     `json:"biome"`
	Effects      []Effect  `json:"effects"`
	Sector       Sector    `json:"sector"`
}

var errorPlanet = err.NewError("[planet]")

func (p *Planet) NewPlanet() *model.Planet {
	return &model.Planet{
		Name:         p.Name,
		MaxHealth:    p.MaxHealth,
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

func (p *Planet) NewSector() *model.Sector {
	return &model.Sector{
		HelldiversID: p.Sector.HelldiversID,
		Name:         p.Sector.Name,
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
			newSector := planet.NewSector()

			// Find the index of the current planet's biome in the biomes slice
			planetBiomeIndex := slices.IndexFunc(*biomes, func(biome model.Biome) bool {
				return biome.Name == planet.Biome.Name
			})

			if planetBiomeIndex == -1 {
				return errorPlanet.Error(nil, fmt.Sprintf("biome %s not found", planet.Biome.Name))
			}

			// Set the new planet's biome and biome ID
			newPlanet.Biome = (*biomes)[planetBiomeIndex]
			newPlanet.BiomeID = (*biomes)[planetBiomeIndex].ID

			owner, err := getFaction(planet.Owner)
			if err != nil {
				return errorPlanet.Error(err, "error getting owner faction")
			}

			initialOwner, err := getFaction(planet.InitialOwner)
			if err != nil {
				return errorPlanet.Error(err, "error getting initial owner faction")
			}

			newPlanet.Owner = owner
			newPlanet.InitialOwner = initialOwner

			// Create the new sector
			err = tx.Omit(clause.Associations).Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"name"}),
			}).Create(&newSector).Error

			if err != nil {
				return errorPlanet.Error(err, "error creating sector")
			}

			// Add the foreign key to the planet
			newPlanet.SectorID = newSector.ID

			// Find the index of the current planet's effects in the effects slice
			planetEffects := make([]model.Effect, len(planet.Effects))
			for i, effect := range planet.Effects {
				planetEffectIndex := slices.IndexFunc(*effects, func(e model.Effect) bool {
					return e.Name == effect.Name
				})

				if planetEffectIndex == -1 {
					return errorPlanet.Error(nil, fmt.Sprintf("effect %s not found", effect.Name))
				}

				planetEffects[i] = (*effects)[planetEffectIndex]
			}

			// Create the new planet
			err = tx.Omit(clause.Associations).Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "name"}},
				DoUpdates: clause.AssignmentColumns([]string{"max_health", "disabled", "owner", "initial_owner", "regeneration", "position_x", "position_y", "helldivers_id", "image_url"}),
			}).Create(&newPlanet).Error

			if err != nil {
				return errorPlanet.Error(err, "error creating planet")
			}

			// Add the foreign key to the statistic
			newStatistic.PlanetID = newPlanet.ID

			// Create the new statistic
			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"mission_time", "bug_kills", "automaton_kills", "illuminate_kills", "bullets_fired", "bullets_hit", "time_played", "deaths", "revives", "friendly_kills", "mission_success_rate", "accuracy"}),
			}).Create(&newStatistic).Error

			if err != nil {
				return errorPlanet.Error(err, "error creating statistic")
			}

			if err := tx.Omit("Effects.*").Model(&newPlanet).Association("Effects").Append(&planetEffects); err != nil {
				return errorPlanet.Error(err, "error when associating effects to planet")
			}
		}

		return nil
	})

	if err != nil {
		return errorPlanet.Error(err, "error when creating planets")
	}

	return nil
}

// Get all planets from the HellHub API and store them in the database
func storePlanets(environment Environment, totalPage int) error {
	db := db.GetDB()

	// Channel to send errors from the goroutines for each page
	errch := make(chan error, totalPage)
	pwg := &sync.WaitGroup{}

	pwg.Add(totalPage)
	for i := range totalPage {
		go func() {
			start := i * 100
			planet, err := fetch[Planet](fmt.Sprintf("/planets?start=%d&limit=100&include[]=statistic&include[]=effects&include[]=biome&include[]=sector", start))
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
		}()
	}

	// Wait for all the goroutines to finish
	pwg.Wait()
	close(errch)

	// Check if there was an error fetching any of the pages
	for err := range errch {
		if err != nil {
			return err
		}
	}

	return nil
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
