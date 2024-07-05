package server

import (
	"errors"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

func (s *Server) OAuthMiddleware(c *gin.Context) {
	db := s.db.GetDB()

	tokenString, err := c.Cookie("token")
	if err != nil {
		s.UnauthorizedResponse(c, "you need to be authenticated to access this route")
		return
	}

	// Verify the token
	_, err = utils.VerifyToken(tokenString)
	if err != nil {
		if err.Error() == utils.ExpiredToken {
			// Delete the token from the database
			if err := db.Unscoped().Delete(&model.Token{}, "token = ?", tokenString).Error; err != nil {
				s.InternalErrorResponse(c, err)
				return
			}

			// Delete the cookie
			utils.DeleteCookieToken(c)

			s.UnauthorizedResponse(c, "token expired")
			return
		}

		if err.Error() == utils.InvalidToken {
			s.UnauthorizedResponse(c, "invalid token")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Get the user from the database
	var token model.Token

	err = db.Preload("User").First(&token, "token = ?", tokenString).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.NotFoundResponse(c, "user")
			return
		}

		s.InternalErrorResponse(c, err)
		return
	}

	// Set the token in the context
	c.Set("token", token.Token)

	// Set the user in the context
	c.Set("user", token.User)

	c.Next()
}
