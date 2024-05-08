package gather

import (
	"fmt"
	"io"
	"net/http"
)

func getPlanets() {
	resp, err := http.Get(fmt.Sprintf("%s/api/planets", HELLHUB_API_URL))
	if err != nil {
		fmt.Println("No response from request")
	}

	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body) // response body is []byte

	if err != nil {
		fmt.Println("Error reading response body")
	}

	fmt.Println(string(body))
}
