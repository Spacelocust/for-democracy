package server

import (
	"errors"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/password"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterLoginRoutes(r *gin.Engine) {
	route := r.Group("/login")

	route.GET("", s.Login)
}

// @Summary Login
// @Description Login
// @Tags login
// @Produce json
// @Param password path string true "Plain password"
// @Param username path string true "Username"
// @Success 200 {object} bool
// @Failure 500  {object}  server.ErrorResponse
// @Router /login [post]
func (s *Server) Login(c *gin.Context) {
	db := s.db.GetDB()

	plainPassword := c.Param("password")
	username := c.Param("username")

	var user model.User

	if err := db.First(&user, "username = ?", username).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.BadRequestResponse(c, "Invalid credentials")

			return
		}

		s.InternalErrorResponse(c, err)

		return
	}

	hash := user.Password

	match, err := password.ComparePasswordAndHash(plainPassword, *hash)

	if err != nil {
		print(err)

		return
	}

	c.JSON(http.StatusOK, match)
}
