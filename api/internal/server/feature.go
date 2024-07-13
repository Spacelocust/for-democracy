package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterFeatureRoutes(r *gin.Engine) {
	route := r.Group("/features")

	route.GET("", s.GetFeatures)
}

// @Summary Get features
// @Description Get features
// @Tags features
// @Produce json
// @Success 200 {array} model.Feature
// @Failure 500  {object}  server.ErrorResponse
// @Router /features [get]
func (s *Server) GetFeatures(c *gin.Context) {
	db := s.db.GetDB()

	var features []model.Feature

	if err := db.Find(&features).Error; err != nil {
		s.InternalErrorResponse(c, err)

		return
	}

	c.JSON(http.StatusOK, features)
}
