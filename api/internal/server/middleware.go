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
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Token missing"})
		return
	}

	// Verify the token
	_, err = utils.VerifyToken(tokenString)
	if err.Error() == utils.ExpiredToken {
		// Delete the token from the database
		db.Delete(&model.Token{}, "token = ?", tokenString)

		// Delete the cookie
		c.SetCookie("token", "", -1, "/", "", false, true)
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Token expired"})
		return
	}

	if err.Error() == utils.InvalidToken {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
		return
	}

	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "Unauthorized"})
		return
	}

	// Get the user from the database
	var user model.User
	err = db.Model(&model.Token{}).Where("token = ?", tokenString).Association("User").Find(&user)
	if err != nil {
		c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "User not found"})
		return
	}

	// Set the user in the context
	c.Set("user", user)
	c.Next()
}
