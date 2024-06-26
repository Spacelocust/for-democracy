package hellhub

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"

	"github.com/goccy/go-json"

	"github.com/Spacelocust/for-democracy/internal/collector/helldivers"
	"github.com/Spacelocust/for-democracy/internal/model"
	"gorm.io/gorm"
)

// fetch makes a GET request to the Hellhub API and unmarshals the response into a slice of T
func fetch[T any](url string) ([]T, error) {
	var data struct {
		List []T `json:"data"`
	}

	resp, err := http.Get(fmt.Sprintf("%s%s%s", os.Getenv("HELLHUB_API_URL"), "/api", url))
	if err != nil {
		return nil, fmt.Errorf("failed to make HTTP request: %w", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, fmt.Errorf("failed to read response body: %w", err)
	}

	if err := json.Unmarshal(body, &data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return data.List, nil
}

// Number of goroutines to use for fetching data
const goroutines = 6

func GetData(db *gorm.DB) error {
	// Channel to send errors from the goroutines
	errpch := make(chan error, goroutines)
	wg := &sync.WaitGroup{}

	environment := Environment{
		biomes:             &[]model.Biome{},
		effects:            &[]model.Effect{},
		sectors:            &[]model.Sector{},
		statistics:         &map[int]model.Statistic{},
		waypointsPerPlanet: &map[int][]model.Waypoint{},
	}

	wg.Add(goroutines)

	// Using go routines to fetch data concurrently
	go storeStratagems(db, errpch, wg)
	go storeBiomes(db, environment.biomes, errpch, wg)
	go storeEffects(db, environment.effects, errpch, wg)
	go storeSectors(db, environment.sectors, errpch, wg)

	go helldivers.FetchStatistics(environment.statistics, errpch, wg)
	go helldivers.FetchWaypointsPerPlanet(environment.waypointsPerPlanet, errpch, wg)

	wg.Wait()
	close(errpch)

	for err := range errpch {
		if err != nil {
			return err
		}
	}

	if err := storePlanets(db, environment, 3); err != nil {
		return err
	}

	return nil
}
