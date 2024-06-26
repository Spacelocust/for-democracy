package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/server/sse"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// Recovery middleware recovers from any panics and writes a 500 if there was one.
	r.Use(gin.Recovery())

	// Root
	s.RegisterRootRoutes(r)

	// Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	// Health check
	r.GET("/healthz", s.HealthHandler)

	s.RegisterOauthRoutes(r)
	s.RegisterPlanetRoutes(r)
	s.RegisterEventRoutes(r)

	// Create a new server for streaming planets and register the route for it
	sse.NewServer(&s.db).PlanetsStream(r)

	return r
}

func (s *Server) HealthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, s.db.Health())
}
