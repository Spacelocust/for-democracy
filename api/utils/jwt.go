package utils

import (
	"fmt"
	"os"
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/golang-jwt/jwt/v5"
)

func CreateToken(user model.User) (string, error) {
	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": user.Username,                    // Subject (user identifier)
		"iss": os.Getenv("SITE_BASE_URL"),       // Issuer
		"aud": user.Role,                        // Audience (user role)
		"exp": time.Now().Add(time.Hour).Unix(), // Expiration time
		"iat": time.Now().Unix(),                // Issued at
	})

	tokenString, err := claims.SignedString([]byte(os.Getenv("JWT_SECRET")))
	if err != nil {
		return "", err
	}

	// Print information about the created token
	fmt.Printf("Token claims added: %+v\n", claims)
	return tokenString, nil
}
