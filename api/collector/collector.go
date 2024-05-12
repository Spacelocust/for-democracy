package collector

import (
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/bytedance/sonic"
)

type Data[t any] struct {
	List []t `json:"data"`
}

// Make a request to the HellHub API and returns the data from a specific endpoint
func getData[t any](url string) ([]t, error) {
	var data Data[t]

	resp, err := http.Get(fmt.Sprintf("%s/api%s", os.Getenv("HELLHUB_API_URL"), url))
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

func GatherData() {
	// getPlanets()
	// err = getBiomes()
	// err = getEffects()
	// err = getStatistics()
	// err = getStratagems()
}
