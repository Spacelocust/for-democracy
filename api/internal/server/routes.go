package server

import (
	"net/http"
	"os"

	"github.com/Spacelocust/for-democracy/internal/server/sse"
	"github.com/gin-gonic/gin"
	swaggerfiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func CORS() gin.HandlerFunc {
    return func(c *gin.Context) {
        c.Writer.Header().Set("Access-Control-Allow-Origin", os.Getenv("API_CORS_ORIGIN"))
        c.Writer.Header().Set("Access-Control-Allow-Credentials", "true")
        c.Writer.Header().Set("Access-Control-Allow-Headers", "Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization, accept, origin, Cache-Control, X-Requested-With")
        c.Writer.Header().Set("Access-Control-Allow-Methods", "POST, OPTIONS, GET, PUT, DELETE, PATCH")

        if c.Request.Method == "OPTIONS" {
            c.AbortWithStatus(204)
            return
        }

        c.Next()
    }
}

func (s *Server) RegisterRoutes() http.Handler {
	r := gin.Default()

	// corsDefault := cors.DefaultConfig()
	// corsDefault.AllowOrigins = []string{"https://google.com"}
	// corsDefault.AllowCredentials = true

	// Cors middleware
	r.Use(CORS())

	// Root
	s.RegisterRootRoutes(r)

	// Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerfiles.Handler))

	// Health check
	r.GET("/healthz", s.HealthHandler)

	// Register routes
	s.RegisterAdminAuthRoutes(r)
	s.RegisterEventRoutes(r)
	s.RegisterFeatureRoutes(r)
	s.RegisterGroupRoutes(r)
	s.RegisterMissionRoutes(r)
	s.RegisterOauthRoutes(r)
	s.RegisterObjectiveRoutes(r)
	s.RegisterPlanetRoutes(r)
	s.RegisterStratagemRoutes(r)
	s.RegisterTokenFcmRoutes(r)
	s.RegisterUsersRoutes(r)

	// Create a new server for streaming planets and events and register the route for them
	sse.NewServer(&s.db).PlanetsStream(r)
	sse.NewServer(&s.db).EventsStream(r)

	return r
}

func (s *Server) HealthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, s.db.Health())
}
