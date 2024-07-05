package server

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) OAuthMiddleware(c *gin.Context) {
	db := s.db.GetDB()

	tokenString, err := c.Cookie("token")
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "you need to be authenticated to access this route"})
		return
	}

	// Verify the token
	_, err = utils.VerifyToken(tokenString)
	if err != nil {
		if err.Error() == utils.ExpiredToken {
			// Delete the token from the database
			db.Unscoped().Delete(&model.Token{}, "token = ?", tokenString)

			// Delete the cookie
			utils.DeleteCookieToken(c)

			c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "token expired"})
			return
		}

		if err.Error() == utils.InvalidToken {
			c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: "invalid token"})
			return
		}

		c.AbortWithStatusJSON(http.StatusInternalServerError, ErrorResponse{Error: SERVER_ERROR_MESSAGE})
		return
	}

	// Get the user from the database
	var token model.Token

	err = db.Preload("User").First(&token, "token = ?", tokenString).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: fmt.Sprintf(NOT_FOUND_MESSAGE, "user")})
			return
		}

		c.AbortWithStatusJSON(http.StatusUnauthorized, ErrorResponse{Error: SERVER_ERROR_MESSAGE})
		return
	}

	// Set the token in the context
	c.Set("token", token.Token)

	// Set the user in the context
	c.Set("user", token.User)

	c.Next()
}
