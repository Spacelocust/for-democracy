package helldivers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"

	"github.com/goccy/go-json"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type PlanetStatus struct {
	Index        int     `json:"index"`
	Health       int     `json:"health"`
	Players      int     `json:"players"`
	Owner        int     `json:"owner"`
	Regeneration float64 `json:"regenPerSecond"`
}

func fetchWar[T any](url string) (T, error) {
	var war T

	resp, err := http.Get(fmt.Sprintf("%s%s%s", os.Getenv("HELLDIVERS_URL"), "/raw/api", url))
	if err != nil {
		return war, fmt.Errorf("failed to make HTTP request: %w", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return war, fmt.Errorf("failed to read response body: %w", err)
	}
	if err := json.Unmarshal(body, &war); err != nil {
		return war, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return war, nil
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

func GetData(db *gorm.DB) error {
	// Channel to send errors from the goroutines
	errpch := make(chan error, 2)
	wg := &sync.WaitGroup{}

	wg.Add(2)

	// Using go routines to fetch data concurrently
	go storeDefences(db, errpch, wg)
	go storeLiberations(db, errpch, wg)

	wg.Wait()
	close(errpch)

	for err := range errpch {
		if err != nil {
			return err
		}
	}

	return nil
}
