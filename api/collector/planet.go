package collector

import (
	"fmt"
	"slices"

	"github.com/Spacelocust/for-democracy/db"
	"github.com/Spacelocust/for-democracy/db/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

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

// Get all planets from the HellHub API
func loadPlanets(planets *[]Planet, totalPage int) error {
	for i := 0; i < totalPage; i++ {
		start := i * 100
		ps, err := getData[Planet](fmt.Sprintf("/planets?start=%d&limit=100&include[]=statistic&include[]=effects&include[]=biome", start))

		if err != nil {
			return fmt.Errorf("error getting planets: %w", err)
		}

		*planets = append(*planets, ps...)
	}

	return nil
}

// Store all planets in the database
func getPlanets() error {
	db := db.GetDB()

	var err error

	var biomes []model.Biome
	var effects []model.Effect
	var planets []Planet

	if err = getBiomes(&biomes); err != nil {
		return err
	}

	if err = getEffects(&effects); err != nil {
		return err
	}

	if err = loadPlanets(&planets, 3); err != nil {
		return err
	}

	if len(planets) > 0 {
		err := db.Transaction(func(tx *gorm.DB) error {
			for _, planet := range planets {
				newPlanet := model.Planet{
					Name:         planet.Name,
					Health:       planet.Health,
					MaxHealth:    planet.MaxHealth,
					Players:      planet.Players,
					Disabled:     planet.Disabled,
					Regeneration: planet.Regeneration,
					PositionX:    planet.PositionX,
					PositionY:    planet.PositionY,
					HelldiversID: planet.HelldiversID,
					ImageURL:     planet.ImageURL,
				}

				newStatistic := model.Statistic{
					HelldiversID:       planet.HelldiversID,
					MissionsWon:        planet.Statistic.MissionsWon,
					MissionTime:        planet.Statistic.MissionTime,
					BugKills:           planet.Statistic.BugKills,
					AutomatonKills:     planet.Statistic.AutomatonKills,
					IlluminateKills:    planet.Statistic.IlluminateKills,
					BulletsFired:       planet.Statistic.BulletsFired,
					BulletsHit:         planet.Statistic.BulletsHit,
					TimePlayed:         planet.Statistic.TimePlayed,
					Deaths:             planet.Statistic.Deaths,
					Revives:            planet.Statistic.Revives,
					FriendlyKills:      planet.Statistic.FriendlyKills,
					MissionSuccessRate: planet.Statistic.MissionSuccessRate,
					Accuracy:           planet.Statistic.Accuracy,
				}

				planetBiomeIndex := slices.IndexFunc(biomes, func(biome model.Biome) bool {
					return biome.Name == planet.Biome.Name
				})

				if planetBiomeIndex == -1 {
					return fmt.Errorf("biome %s not found", planet.Biome.Name)
				}

				newPlanet.Biome = biomes[planetBiomeIndex]
				newPlanet.BiomeID = biomes[planetBiomeIndex].ID

				planetEffects := make([]model.Effect, len(planet.Effects))
				for i, effect := range planet.Effects {
					planetEffectIndex := slices.IndexFunc(effects, func(e model.Effect) bool {
						return e.Name == effect.Name
					})

					if planetEffectIndex == -1 {
						return fmt.Errorf("effect %s not found", effect.Name)
					}

					planetEffects[i] = effects[planetEffectIndex]
				}

				newPlanet.Effects = planetEffects

				err = tx.Omit(clause.Associations).Clauses(clause.OnConflict{
					Columns:   []clause.Column{{Name: "name"}},
					DoUpdates: clause.AssignmentColumns([]string{"health", "max_health", "players", "disabled", "regeneration", "position_x", "position_y", "helldivers_id", "image_url"}),
				}).Create(&newPlanet).Error

				if err != nil {
					return fmt.Errorf("error creating planet: %v", err)
				}

				newStatistic.PlanetID = newPlanet.ID

				err = tx.Clauses(clause.OnConflict{
					Columns:   []clause.Column{{Name: "helldivers_id"}},
					DoUpdates: clause.AssignmentColumns([]string{"mission_time", "bug_kills", "automaton_kills", "illuminate_kills", "bullets_fired", "bullets_hit", "time_played", "deaths", "revives", "friendly_kills", "mission_success_rate", "accuracy"}),
				}).Create(&newStatistic).Error

				if err != nil {
					return fmt.Errorf("error creating statistic: %v", err)
				}

				if err := tx.Model(&newPlanet).Association("Statistic").Append(&newStatistic); err != nil {
					return fmt.Errorf("error associating statistic with planet: %v", err)
				}
			}

			return nil
		})

		if err != nil {
			return fmt.Errorf("error creating planets: %v", err)
		}
	}

	return nil
}
