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
	r.POST("/login", s.Login)
	r.GET("/logout", s.AuthMiddleware, s.Logout)
}

// @Summary Login
// @Description Admin login
// @Tags authentication
// @Accept  json
// @Produce json
// @Param data body validators.Admin true "Admin data"
// @Success 200 {object} bool
// @Failure 500  {object}  server.ErrorResponse
// @Router /login [post]
func (s *Server) Login(c *gin.Context) {
	db := s.db.GetDB()

	// Get data from request body and validate
	var adminData validators.Admin
	
	// Bind JSON request to Group struct
	if err := c.ShouldBindJSON(&adminData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	// Validate Group struct
	if err := s.validator.Validate(adminData); err != nil {
		s.BadRequestResponse(c, err.Error())
		return
	}

	var user model.User

	if err := db.First(&user, "username = ?", adminData.Username).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.BadRequestResponse(c, "Invalid credentials")

			return
		}

		s.InternalErrorResponse(c, err)

		return
	}

	hash := *user.Password

	match, err := password.ComparePasswordAndHash(adminData.Password, hash)

	if err != nil {
		s.InternalErrorResponse(c, err)

		return
	}

	if !match {
		s.BadRequestResponse(c, "Invalid credentials")

		return
	}

	user.Password = nil

	tokenString, err := utils.CreateToken(user)

	if err != nil {
		s.InternalErrorResponse(c, err)

		return
	}

	if err := db.Create(&model.Token{
		Token:  tokenString,
		UserId: user.ID,
	}).Error; err != nil {
		s.InternalErrorResponse(c, err)

		return
	}

	utils.CreateCookieToken(tokenString, c)

	c.JSON(http.StatusOK, user)
}

// @Summary	    Log the user out
// @Description Route used to log the user out
// @Tags        authentication
// @Produce     json
// @Success     200
// @Failure     401  {object}  server.ErrorResponse
// @Failure     500  {object}  server.ErrorResponse
// @Router      /logout [get]
func (s *Server) Logout(c *gin.Context) {
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
