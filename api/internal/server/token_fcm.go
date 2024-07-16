package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterTokenFcmRoutes(r *gin.Engine) {
	route := r.Group("/token-fcm")
	route.Use(s.OAuthMiddleware)

	route.POST("", s.PersistToken)
}

// @Summary			 Persist the FCM token
// @Description  Route used to persist the FCM token
// @Tags         token-fcm
// @Accept       json
// @Produce      json
// @Param data body validators.TokenFcm true "Token data"
// @Success      200  {object}  server.SuccessResponse
// @Success			 201  {object}  server.SuccessResponse
// @Failure      401  {object}  server.ErrorResponse
// @Failure      403  {object}  server.ErrorResponse
// @Failure      404  {object}  server.ErrorResponse
// @Failure      500  {object}  server.ErrorResponse
// @Router       /token-fcm [post]
func (s *Server) PersistToken(c *gin.Context) {
	db := s.db.GetDB()

	// Check if the user is authenticated
	user := checkAuth(c)

	var tokenFcmData validators.TokenFcm

	if err := c.ShouldBindJSON(&tokenFcmData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate GroupCode struct
	if err := s.validator.Validate(tokenFcmData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	var tokenFcm model.TokenFcm

	// Find an existing token
	if err := db.Find(&tokenFcm, "user_id = ?", user.ID).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	// Update the token
	tokenFcm.Token = tokenFcmData.Token
	tokenFcm.UserID = user.ID

	if err := db.Save(&tokenFcm).Error; err != nil {
		s.InternalErrorResponse(c, err)
		return
	}

	c.JSON(http.StatusOK, SuccessResponse{Message: "Token persist successfully"})
}
