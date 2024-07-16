package server

import (
	"errors"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterStratagemRoutes(r *gin.Engine) {
	route := r.Group("/stratagems")

	route.GET("", s.GetStratagems)
	route.GET("/:id", s.GetStratagem)
}

// @Summary Get all stratagems
// @Description Get all stratagems
// @Tags    stratagems
// @Produce  json
// @Success 200 {array} model.Stratagem
// @Failure      500  {object}  server.ErrorResponse
// @Router /stratagems [get]
func (s *Server) GetStratagems(c *gin.Context) {
	db := s.db.GetDB()

	var stratagems []model.Stratagem

	if err := db.Not("use_type = ?", enum.Shared).Find(&stratagems).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, stratagems)
}

// @Summary Get a stratagem
// @Description Get a stratagem
// @Tags    stratagems
// @Produce  json
// @Param id path string true "Stratagem ID"
// @Success 200 {object} model.Stratagem
// @Failure      404  {object}  server.ErrorResponse
// @Failure      500  {object}  server.ErrorResponse
// @Router /stratagems/{id} [get]
func (s *Server) GetStratagem(c *gin.Context) {
	db := s.db.GetDB()

	id := c.Param("id")

	var stratagem model.Stratagem

	if err := db.First(&stratagem, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "stratagem")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, stratagem)
}
