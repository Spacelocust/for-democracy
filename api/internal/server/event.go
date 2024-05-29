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
// @Failure      500  {object}  gin.Error
// @Router       /events [get]
func (s *Server) GetEvents(c *gin.Context) {
	db := s.db.GetDB()

	// Get all events
	defences := []model.Defence{}
	liberations := []model.Liberation{}

	if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Find(&defences).Error; err != nil {
		if err := c.AbortWithError(http.StatusInternalServerError, err); err != nil {
			return
		}
	}

	if err := db.Preload("Planet.Statistic").Preload("Planet.Biome").Preload("Planet.Effects").Find(&liberations).Error; err != nil {
		if err := c.AbortWithError(http.StatusInternalServerError, err); err != nil {
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{
		"defences":    defences,
		"liberations": liberations,
	})
}
