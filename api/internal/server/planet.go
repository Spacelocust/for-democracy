package server

import (
	"errors"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func (s *Server) RegisterPlanetRoutes(r *gin.Engine) {
	r.GET("/planets", s.GetPlanets)
	r.GET("/planets-event", s.GetPlanetsWithEvent)
	r.GET("/planets/:id", s.GetPlanet)
}

// @Summary			 Get all planets
// @Description  Get all planets
// @Tags         planets
// @Produce      json
// @Success      200  {array}  model.Planet
// @Failure      500  {object}  server.ErrorResponse
// @Router       /planets [get]
func (s *Server) GetPlanets(c *gin.Context) {
	db := s.db.GetDB()

	var planets []model.Planet

	if err := db.Preload(clause.Associations).Find(&planets).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, planets)
}

// @Summary			 Get all planets with events
// @Description  Get all planets with events
// @Tags         planets
// @Produce      json
// @Success      200  {array}  model.Planet
// @Failure      500  {object}  server.ErrorResponse
// @Router       /planets-event [get]
func (s *Server) GetPlanetsWithEvent(c *gin.Context) {
	db := s.db.GetDB()

	var planets []model.Planet

	// Get only planets with events liberations or defences
	err := db.Preload("Liberation").Preload("Defence").
		Joins("LEFT JOIN liberations ON liberations.planet_id = planets.id").
		Joins("LEFT JOIN defences ON defences.planet_id = planets.id").
		Where("liberations.id IS NOT NULL AND liberations.deleted_at IS NULL OR defences.id IS NOT NULL AND defences.deleted_at IS NULL").
		Find(&planets).Error

	if err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, planets)
}

// @Summary			 Get planet by ID
// @Description  Get planet by ID
// @Tags         planets
// @Produce      json
// @Param        id   path      int  true  "Planet ID"
// @Success      200  {object}  model.Planet
// @Failure      500  {object}  server.ErrorResponse
// @Router       /planets/{id} [get]
func (s *Server) GetPlanet(c *gin.Context) {
	db := s.db.GetDB()

	id := c.Param("id")

	var planet model.Planet

	// Get the planet
	if err := db.Preload(clause.Associations).First(&planet, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "planet")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, planet)
}
