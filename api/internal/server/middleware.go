package server

import (
	"net/http"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/Spacelocust/for-democracy/utils"
	"github.com/gin-gonic/gin"
)

func (s *Server) OAuthMiddleware(c *gin.Context) {
	db := s.db.GetDB()

	tokenString, err := c.Cookie("token")
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token missing"})
		return
	}

	// Verify the token
	_, err = utils.VerifyToken(tokenString)
	if err != nil {
		if err.Error() == utils.ExpiredToken {
			// Delete the token from the database
			db.Unscoped().Delete(&model.Token{}, "token = ?", tokenString)

			// Delete the cookie
			c.SetCookie("token", "", -1, "/", "", false, true)
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "token expired"})
			return
		}

		if err.Error() == utils.InvalidToken {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid token"})
			return
		}

		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
		return
	}

	// Get the user from the database
	var token model.Token
	err = db.Preload("User").First(&token, "token = ?", tokenString).Error
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
		return
	}

	// // Set the user in the context
	c.Set("user", token.User)
	c.Next()
}
