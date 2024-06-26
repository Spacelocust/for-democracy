package hellhub

import (
	"fmt"
	"slices"
	"strings"
	"sync"

	err "github.com/Spacelocust/for-democracy/error"
	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

var bgUrl = "https://helldiverscompanion.com/biomes/"

type Environment struct {
	biomes             *[]model.Biome
	effects            *[]model.Effect
	sectors            *[]model.Sector
	statistics         *map[int]model.Statistic
	waypointsPerPlanet *map[int][]model.Waypoint
}

type Planet struct {
	HelldiversID int      `json:"index"`
	Name         string   `json:"name"`
	MaxHealth    int      `json:"maxHealth"`
	Disabled     bool     `json:"disabled"`
	PositionX    float64  `json:"positionX"`
	PositionY    float64  `json:"positionY"`
	ImageURL     string   `json:"imageURL"`
	Owner        int      `json:"ownerId"`
	InitialOwner int      `json:"initialOwnerId"`
	Biome        Biome    `json:"biome"`
	Effects      []Effect `json:"effects"`
	Sector       Sector   `json:"sector"`
}

var errorPlanet = err.NewError("[planet]")

func (p *Planet) NewPlanet() *model.Planet {
	return &model.Planet{
		Name:         p.Name,
		MaxHealth:    p.MaxHealth,
		Disabled:     p.Disabled,
		PositionX:    p.PositionX,
		PositionY:    p.PositionY,
		HelldiversID: p.HelldiversID,
		ImageURL:     p.ImageURL,
	}
}

// Store the planets in the database
func persistPlanets(db *gorm.DB, planets []Planet, environnement Environment) error {
	biomes := environnement.biomes
	effects := environnement.effects
	sectors := environnement.sectors
	statistics := environnement.statistics
	waypointsPerPlanet := environnement.waypointsPerPlanet

	err := db.Transaction(func(tx *gorm.DB) error {
		for _, planet := range planets {

			// Create a new model.Planet and model.Statistic
			newPlanet := planet.NewPlanet()

			// Find the waypoints for the current planet
			if waypoint, ok := (*waypointsPerPlanet)[planet.HelldiversID]; ok {
				newPlanet.Waypoints = waypoint
			}

			// Find the index of the current planet's biome in the biomes slice
			planetBiomeIndex := slices.IndexFunc(*biomes, func(biome model.Biome) bool {
				return biome.Name == planet.Biome.Name
			})

			if planetBiomeIndex == -1 {
				return errorPlanet.Error(nil, fmt.Sprintf("biome %s not found", planet.Biome.Name))
			}

			// Set the new planet's biome and biome ID
			newPlanet.BiomeID = (*biomes)[planetBiomeIndex].ID

			// Set the new planet's background URL
			newPlanet.BackgroundURL = getBiomeBackgrounds(planet.Biome.Name)

			// Set the new planet's image URL
			if planet.Biome.Name == "Tundra" {
				newPlanet.ImageURL = strings.Replace(planet.ImageURL, "tundra", "canyon", 1)
			}

			// Find the owner and initial owner factions
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

			// Find the index of the current planet's sector in the sectors slice
			planetSectorIndex := slices.IndexFunc(*sectors, func(sector model.Sector) bool {
				return sector.Name == planet.Sector.Name
			})

			if planetSectorIndex == -1 {
				return errorPlanet.Error(nil, fmt.Sprintf("sector %s not found", planet.Sector.Name))
			}

			newPlanet.SectorID = (*sectors)[planetSectorIndex].ID

			// Create the new planet
			err = tx.Omit(clause.Associations).Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "name"}},
				DoUpdates: clause.AssignmentColumns([]string{"max_health", "disabled", "owner", "initial_owner", "position_x", "position_y", "helldivers_id", "image_url", "background_url", "waypoints"}),
			}).Create(&newPlanet).Error

			if err != nil {
				return errorPlanet.Error(err, "error creating planet")
			}

			// Add the foreign key to the statistic
			newStatistic := model.Statistic{}
			if statistic, ok := (*statistics)[planet.HelldiversID]; ok {
				newStatistic = statistic
			}

			newStatistic.PlanetID = newPlanet.ID

			// Create the new statistic
			err = tx.Clauses(clause.OnConflict{
				Columns:   []clause.Column{{Name: "helldivers_id"}},
				DoUpdates: clause.AssignmentColumns([]string{"missions_won", "missions_lost", "mission_time", "bug_kills", "automaton_kills", "illuminate_kills", "bullets_fired", "bullets_hit", "time_played", "deaths", "revives", "friendly_kills", "mission_success_rate", "accuracy"}),
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
func storePlanets(db *gorm.DB, environment Environment, totalPage int) error {
	// Channel to send errors from the goroutines for each page
	errch := make(chan error, totalPage)
	pwg := &sync.WaitGroup{}

	pwg.Add(totalPage)
	for i := range totalPage {
		go func(i int) {
			start := i * 100
			planet, err := fetch[Planet](fmt.Sprintf("/planets?start=%d&limit=100&include[]=effects&include[]=biome&include[]=sector", start))
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
		}(i)
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

var coorealationBiomeBackground = map[string]string{
	"Toxic":           "acidic",
	"Unknown":         "superearth",
	"Tundra":          "taiga",
	"Icemoss Special": "cyberstan",
	"Crimsonmoor":     "crimson",
	"Desolate":        "inferno",
}

var coorelationPlanetBackground = map[string]string{
	"Meridia": "meridia",
}

// Get the background image URL from the biome name
func getBiomeBackgrounds(name string) string {
	if bg, ok := coorealationBiomeBackground[name]; ok {
		return fmt.Sprintf("%s%s%s", bgUrl, bg, ".webp")
	}

	if bg, ok := coorelationPlanetBackground[name]; ok {
		return fmt.Sprintf("%s%s%s", bgUrl, bg, ".webp")
	}

	return fmt.Sprintf("%s%s%s", bgUrl, strings.ReplaceAll(strings.ToLower(name), " ", "_"), ".webp")
}
