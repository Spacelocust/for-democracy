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

// GetData makes a request to the HellHub API and returns the data from a specific endpoint
func getData[t any](url string) ([]t, error) {
	var data Data[t]

	resp, err := http.Get(fmt.Sprintf("%s/api%s", os.Getenv("HELLHUB_API_URL"), url))
	if err != nil {
		fmt.Println("No response from request")
	}

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)

	sonic.Unmarshal(body, &data)

	if err != nil {
		fmt.Println("Error reading response body")
	}

	return data.List, nil
}

func GatherData() {
	getPlanets()
	getBiomes()
	getEffects()
	getStatistics()
	getStratagems()
}
