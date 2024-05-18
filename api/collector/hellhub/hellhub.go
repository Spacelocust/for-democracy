package hellhub

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"

	"github.com/Spacelocust/for-democracy/db/model"
	"github.com/bytedance/sonic"
)

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

	if err := sonic.Unmarshal(body, &data); err != nil {
		return nil, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return data.List, nil
}

func GetData() error {
	// Channel to send errors from the goroutines
	errpch := make(chan error, 3)
	wg := &sync.WaitGroup{}

	environment := Environment{
		biomes:  &[]model.Biome{},
		effects: &[]model.Effect{},
	}

	wg.Add(3)

	// Using go routines to fetch data concurrently
	go storeStratagems(errpch, wg)
	go storeBiomes(environment.biomes, errpch, wg)
	go storeEffects(environment.effects, errpch, wg)

	wg.Wait()
	close(errpch)

	for err := range errpch {
		if err != nil {
			return err
		}
	}

	if err := storePlanets(environment, 3); err != nil {
		return err
	}

	return nil
}
