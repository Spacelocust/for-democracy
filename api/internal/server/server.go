package server

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/Spacelocust/for-democracy/docs"
	"github.com/go-playground/validator/v10"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/enum"
	_ "github.com/Spacelocust/for-democracy/internal/oauth"
	"github.com/Spacelocust/for-democracy/internal/validators"
)

type Server struct {
	port int

	db        database.Service
	validator validators.Service
}

type ErrorResponse struct {
	Error string `json:"error"`
}

type SuccessResponse struct {
	Message string `json:"message"`
}

func NewServer() *http.Server {
	port, _ := strconv.Atoi(os.Getenv("API_PORT"))
	NewServer := &Server{
		port:      port,
		db:        database.New(),
		validator: validators.New(),
	}

	// Register custom validation rules
	err := NewServer.validator.RegisterValidations(map[string]validator.Func{
		"difficulty":    enum.ValidateDifficulty,
		"objectiveType": enum.ValidateObjectiveType,
		"datetime":      validators.DateTime,
		"gte_datetime":  validators.GteDateTime,
	})

	if err != nil {
		log.Fatal(err)
	}

	docs.SwaggerInfo.Host = fmt.Sprintf("%s:%s", os.Getenv("DOMAIN"), os.Getenv("API_PORT"))
	docs.SwaggerInfo.Schemes = []string{"http", "https"}

	// Declare Server config
	server := &http.Server{
		Addr:        fmt.Sprintf(":%d", NewServer.port),
		Handler:     NewServer.RegisterRoutes(),
		IdleTimeout: time.Minute,
		ReadTimeout: 10 * time.Second,
	}

	server.RegisterOnShutdown(func() {
		if err := NewServer.db.Close(); err != nil {
			log.Fatal(err)
		}
	})

	return server
}
