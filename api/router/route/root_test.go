package route

import (
	"io"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/stretchr/testify/assert"
)

func TestRootRoutes(t *testing.T) {
	assert := assert.New(t)

	test := struct {
		description  string // description of the test case
		route        string // route path to test
		expectedCode int    // expected HTTP status code
		expectedBody string // expected response body
	}{
		description:  "get HTTP status 200 and 'Hello, World!' body",
		route:        "/",
		expectedCode: fiber.StatusOK,
		expectedBody: "Hello, World!",
	}

	// Define Fiber app.
	app := fiber.New()

	// Load Root routes.
	rootRoutes(app)

	// Create a new http request with the route from the test case
	req := httptest.NewRequest("GET", test.route, nil)

	// Get the response from the request
	resp, _ := app.Test(req)

	// Read the body of the response
	body, _ := io.ReadAll(resp.Body)

	// Verify, if the status code is as expected
	assert.Equal(test.expectedCode, resp.StatusCode, test.description)

	// Verify, if the body is as expected
	assert.Equal(test.expectedBody, string(body))
}
