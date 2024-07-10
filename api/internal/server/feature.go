package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterFeatureRoutes(r *gin.Engine) {
	route := r.Group("/features")

	route.GET("/", s.GetFeatures)
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

// func (s *Server) CreateFeature(c *gin.Context) {
// 	db := s.db.GetDB()

// 	// Get data from request body and validate
// 	var featureData validators.Feature

// 	// Bind JSON request to feature struct
// 	if err := c.ShouldBindJSON(&featureData); err != nil {
// 		s.BadRequestResponse(c, err.Error())
// 		return
// 	}

// 	// Validate feature struct
// 	if err := s.validator.Validate(featureData); err != nil {
// 		s.BadRequestResponse(c, err.Error())
// 		return
// 	}
// }
