package helldivers

import (
	"fmt"
	"io"
	"net/http"
	"os"
	"sync"

	"github.com/bytedance/sonic"
)

type PlanetStatus struct {
	Index   int `json:"index"`
	Health  int `json:"health"`
	Players int `json:"players"`
}

func fetchWar[T any](url string) (T, error) {
	var war T

	resp, err := http.Get(fmt.Sprintf("%s%s%s", os.Getenv("HELLDIVERS_API_URL"), "/raw/api", url))
	if err != nil {
		return war, fmt.Errorf("failed to make HTTP request: %w", err)
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return war, fmt.Errorf("failed to read response body: %w", err)
	}

	if err := sonic.Unmarshal(body, &war); err != nil {
		return war, fmt.Errorf("failed to unmarshal response body: %w", err)
	}

	return war, nil
}

func GetData() error {
	// Channel to send errors from the goroutines
	errpch := make(chan error, 2)
	wg := &sync.WaitGroup{}

	wg.Add(2)

	// Using go routines to fetch data concurrently
	go storeDefences(errpch, wg)
	go storeLiberations(errpch, wg)

	wg.Wait()
	close(errpch)

	for err := range errpch {
		if err != nil {
			return err
		}
	}

	return nil
}
