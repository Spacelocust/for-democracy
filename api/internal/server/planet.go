package server

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
	"gorm.io/gorm/clause"
)

func (s *Server) RegisterPlanetRoutes(r *gin.Engine) {
	r.GET("/planets", s.GetPlanets)
	r.GET("/planets/:id", s.GetPlanet)
}

// @Summary			 Get all planets
// @Description  Get all planets
// @Tags         planets
// @Produce      json
// @Success      200  {array}  model.Planet
// @Failure      500  {object}  gin.Error
// @Router       /planets [get]
func (s *Server) GetPlanets(c *gin.Context) {
	db := s.db.GetDB()

	var planets []model.Planet

	if err := db.Preload(clause.Associations).Find(&planets).Error; err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, fmt.Sprintf(ERROR_FETCHING_MESSAGE, "planets"))
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
// @Failure      500  {object}  gin.Error
// @Router       /planets/{id} [get]
func (s *Server) GetPlanet(c *gin.Context) {
	db := s.db.GetDB()

	id := c.Param("id")

	var planet model.Planet

	// Get the planet
	if err := db.Preload(clause.Associations).First(&planet, "id = ?", id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusNotFound, fmt.Sprintf(NOT_FOUND_MESSAGE, "planet"))
			return
		}

		s.logger.Error(err.Error())

		c.JSON(http.StatusInternalServerError, fmt.Sprintf(ERROR_FETCHING_MESSAGE, "planet"))
		return
	}

	c.JSON(http.StatusOK, planet)
}
