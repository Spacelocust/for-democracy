package collector

import (
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/Spacelocust/for-democracy/collector/hellhub"
	"github.com/bytedance/sonic"
)

type Data[T any] struct {
	List []T
}

type DataHellhub[T any] struct {
	List []T `json:"data"`
}

type Fetch struct {
	Url        string
	PathPrefix string
}

func helldiversFetch[T any](url string, prefix ...bool) ([]T, error) {
	url = fmt.Sprintf("%s%s%s", os.Getenv("HELLDIVERS_API_URL"), "/api/v1", url)

	if len(prefix) > 0 && !prefix[0] {
		url = fmt.Sprintf("%s%s", os.Getenv("HELLDIVERS_API_URL"), url)
	}

	var data []T
	resp, err := http.Get(url)
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

	return data, nil
}

func GatherData() {
	if err := hellhub.GetData(); err != nil {
		fmt.Println(err)
	}

	// if err := GetDefences(); err != nil {
	// 	fmt.Println(err)
	// }

	// if err := GetLiberations(); err != nil {
	// 	fmt.Println(err)
	// }
}
