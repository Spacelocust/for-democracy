package utils

import (
	"fmt"
	"os"
	"time"

	"github.com/Spacelocust/for-democracy/internal/model"
	"github.com/golang-jwt/jwt/v5"
)

var secretKey = []byte(os.Getenv("JWT_SECRET"))

var ExpiredToken = "Token expired"
var InvalidToken = "Invalid token"

func CreateToken(user model.User) (string, error) {
	claims := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"sub": *user.SteamId,                    // Subject (user identifier) // Custom payload
		"iss": os.Getenv("SITE_BASE_URL"),       // Issuer
		"aud": user.Role,                        // Audience (user role)
		"exp": time.Now().Add(time.Hour).Unix(), // Expiration time
		"iat": time.Now().Unix(),                // Issued at
	})

	tokenString, err := claims.SignedString(secretKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func VerifyToken(tokenString string) (*jwt.Token, error) {
	// Parse the token with the secret key
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		return secretKey, nil
	})

	// Check for verification errors
	if err != nil {
		return nil, err
	}

	// Check if the token is valid
	if !token.Valid {
		return nil, fmt.Errorf(InvalidToken)
	}

	expiredTime, err := token.Claims.GetExpirationTime()
	if err != nil {
		return nil, fmt.Errorf(InvalidToken)
	}

	if !expiredTime.Before(time.Now()) {
		return nil, fmt.Errorf(ExpiredToken)
	}

	// Return the verified token
	return token, nil
}
