package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/server/sse"
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Cors middleware
	r.Use(cors.Default())

	// Root
	s.RegisterRootRoutes(r)

	// Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	// Health check
	r.GET("/healthz", s.HealthHandler)

	// Register routes
	s.RegisterEventRoutes(r)
	s.RegisterFeatureRoutes(r)
	s.RegisterGroupRoutes(r)
	s.RegisterMissionRoutes(r)
	s.RegisterOauthRoutes(r)
	s.RegisterObjectiveRoutes(r)
	s.RegisterPlanetRoutes(r)
	s.RegisterStratagemRoutes(r)
	s.RegisterUsersRoutes(r)

	// Create a new server for streaming planets and register the route for it
	sse.NewServer(&s.db).PlanetsStream(r)

	return r
}

func (s *Server) HealthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, s.db.Health())
}
