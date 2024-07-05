package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterEventRoutes(r *gin.Engine) {
	r.GET("/events", s.GetEvents)
}

type Event struct {
	Defence    []model.Defence
	Liberation []model.Liberation
}

// @Summary			 Get all events
// @Description  Get all events
// @Tags         events
// @Produce      json
// @Success      200  {object}  server.Event
// @Failure      500  {object} server.ErrorResponse
// @Router       /events [get]
func (s *Server) GetEvents(c *gin.Context) {
	db := s.db.GetDB()

	// Get all events
	var defences []model.Defence
	var liberations []model.Liberation

	if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Preload("Planet.Sector").Find(&defences).Error; err != nil {
		s.InternalErrorResponse(c, err)
	}

	if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Preload("Planet.Sector").Find(&liberations).Error; err != nil {
		s.InternalErrorResponse(c, err)
	}

	c.JSON(http.StatusOK, gin.H{
		"defences":    defences,
		"liberations": liberations,
	})
}
