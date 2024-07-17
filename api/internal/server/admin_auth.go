package server

import (
	"errors"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/internal/validators"
	"github.com/Spacelocust/for-democracy/password"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) RegisterAdminAuthRoutes(r *gin.Engine) {
	route := r.Group("/auth")

	route.GET("/check", s.AuthCheck)
	route.GET("/login", s.AuthLogin)
	route.GET("/logout", s.AuthLogout)
}

// @Summary Auth check
// @Description Check if user password matches hash
// @Tags authentication
// @Produce json
// @Param password path string true "Plain password"
// @Param username path string true "Username"
// @Success 200 {object} bool
// @Failure 500  {object}  server.ErrorResponse
// @Router /auth/check [post]
func (s *Server) AuthCheck(c *gin.Context) {
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

// @Summary		Get the admin user after authentication is complete
// @Description Route used to store the admin token after authentication
// @Tags        authentication
// @Produce     json
// @Param       data body validators.User true "Feature code"
// @Success     200  {object}  goth.User
// @Failure     500  {object}  server.ErrorResponse
// @Router      /auth/login [post]
func (s *Server) AuthLogin(c *gin.Context) {
	db := s.db.GetDB()

	// Get data from request body and validate
	var userData validators.User
	
	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&userData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(userData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Check if the user exists
	var user model.User
	if err := db.Where("username = ?", userData.Username).First(&user).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "group")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	tokenString, err := utils.CreateToken(user)

	if err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	if err := db.Create(&model.Token{
		Token:  tokenString,
		UserId: user.ID,
	}).Error; err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while authenticating the user"})
		return
	}

	utils.CreateCookieToken(tokenString, c)

	c.Data(http.StatusOK, "text/html; charset=utf-8", []byte(pageLoading))
}

// @Summary	    Log the user out
// @Description Route used to log the user out
// @Tags        authentication
// @Produce     json
// @Success     200
// @Failure     401  {object}  server.ErrorResponse
// @Failure     500  {object}  server.ErrorResponse
// @Router      /auth/logout [get]
func (s *Server) AuthLogout(c *gin.Context) {
	db := s.db.GetDB()

	token, ok := c.Get("token")
	if !ok {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: NOT_AUTHENTICATED_MESSAGE})
		return
	}

	q := c.Request.URL.Query()
	c.Request.URL.RawQuery = q.Encode()

	// Delete the token from the database
	if err := db.Unscoped().Delete(&model.Token{}, "token = ?", token).Error; err != nil {
		s.logger.Error(err.Error())
		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: "something happened while logging out the user"})
		return
	}

	// Delete the cookie
	c.SetCookie("token", "", -1, "/", "", false, true)

	c.JSON(http.StatusOK, SuccessResponse{Message: "you have been logged out"})
}
