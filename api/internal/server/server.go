package server

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"github.com/Spacelocust/for-democracy/docs"

	"github.com/Spacelocust/for-democracy/internal/database"
	_ "github.com/Spacelocust/for-democracy/internal/oauth"
)

type Server struct {
	port int

	db database.Service
}

func NewServer() *http.Server {
	port, _ := strconv.Atoi(os.Getenv("API_PORT"))
	NewServer := &Server{
		port: port,
		db:   database.New(),
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
