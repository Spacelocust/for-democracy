package server

import (
	"errors"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterFeatureRoutes(r *gin.Engine) {
	route := r.Group("/features")

	route.GET("/:code", s.GetFeature)
	route.GET("", s.GetFeatures)
	route.PATCH("/:code", s.AuthMiddleware, s.ToggleFeature)
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

// @Summary Get feature
// @Description Get feature
// @Tags features
// @Produce json
// @Param code path string true "Feature code"
// @Success 200 {object} model.Feature
// @Failure 500  {object}  server.ErrorResponse
// @Router /features/{code} [get]
func (s *Server) GetFeature(c *gin.Context) {
	db := s.db.GetDB()

	code := c.Param("code")

	var feature model.Feature

	if err := db.Find(&feature, "code = ?", code).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "feature")

			return
		}

		s.InternalErrorResponse(c, err)

		return
	}

	c.JSON(http.StatusOK, feature)
}

// @Summary Toggle feature
// @Description Toggle feature using code
// @Tags features
// @Produce json
// @Param code path string true "Feature code"
// @Param data body validators.FeatureEnabled true "Properties to update"
// @Success 200 {object} model.Feature
// @Failure      500  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      401  {object}  server.ErrorResponse
// @Failure      400  {object}  server.ErrorResponse
// @Router /features/{code} [patch]
func (s *Server) ToggleFeature(c *gin.Context) {
	db := s.db.GetDB()

	featureCode := c.Param("code")

	// Get data from request body and validate
	var featureData validators.FeatureEnabled

	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&featureData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(featureData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	if err := db.Model(model.Feature{}).Where("code = ?", featureCode).Update("enabled", featureData.Enabled).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "feature")

			return
		}

		s.InternalErrorResponse(c, err)

		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "Feature updated"})
}
