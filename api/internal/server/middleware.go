package server

import (
	"errors"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// OAuthMiddleware is used to check if the user is authenticated
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

// Oauth optionnal middleware is used to allow the endpoint to implement the logic when the user is not authenticated
func (s *Server) OAuthOptionalMiddleware(c *gin.Context) {
	db := s.db.GetDB()

	// Set the token to nil
	c.Set("token", nil)

	// Set the user to nil
	c.Set("user", nil)

	tokenString, err := c.Cookie("token")
	if err != nil {
		s.logger.Info("[oauth-opt]: error getting token from cookie")
		c.Next()
		return
	}

	// Verify the token
	_, err = utils.VerifyToken(tokenString)
	if err != nil {
		if err.Error() == utils.ExpiredToken {
			// Delete the token from the database
			if err := db.Unscoped().Delete(&model.Token{}, "token = ?", tokenString).Error; err != nil {
				s.logger.Info("[oauth-opt]: error deleting token from database")
				c.Next()
				return
			}

			// Delete the cookie
			utils.DeleteCookieToken(c)

			s.logger.Info("[oauth-opt]: token expired")
			c.Next()
			return
		}

		if err.Error() == utils.InvalidToken {
			s.logger.Info("[oauth-opt]: invalid token")
			c.Next()
			return
		}

		s.logger.Error("[oauth-opt]: error verifying token")
		c.Next()
		return
	}

	// Get the user from the database
	var token model.Token

	err = db.Preload("User").First(&token, "token = ?", tokenString).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			s.logger.Info("[oauth-opt]: user not found")
			c.Next()
			return
		}

		c.Next()
		return
	}

	// Set the token in the context
	c.Set("token", token.Token)

	// Set the user in the context
	c.Set("user", token.User)

	c.Next()
}
