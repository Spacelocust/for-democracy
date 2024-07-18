package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/gin-gonic/gin"
)

func (s *Server) RegisterUsersRoutes(r *gin.Engine) {
	route := r.Group("/users")

	route.GET("/admin", s.AuthMiddleware, s.GetAdmin)
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

// @Summary Get admin
// @Description Get admin user
// @Tags users
// @Produce json
// @Success 200 {object} model.User
// @Failure 404  {object}  server.ErrorResponse
// @Failure 500  {object}  server.ErrorResponse
// @Router /users/admin [get]
func (s *Server) GetAdmin(c *gin.Context) {
	admin := checkAuth(c)

	if (admin.Role != "admin") {
		s.ForbiddenResponse(c, "You are not an admin")

		return
	}

	c.JSON(http.StatusOK, admin)
}
