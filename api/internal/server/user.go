package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterUsersRoutes(r *gin.Engine) {
	route := r.Group("/users")

	route.GET("", s.GetUsers)
}

// @Summary Get users
// @Description Get users
// @Tags users
// @Produce json
// @Success 200 {array} model.Feature
// @Failure 500  {object}  server.ErrorResponse
// @Router /users [get]
func (s *Server) GetUsers(c *gin.Context) {
	db := s.db.GetDB()

	var users []model.User

	if err := db.Find(&users).Error; err != nil {
		s.InternalErrorResponse(c, err)

		return
	}

	c.JSON(http.StatusOK, users)
}
