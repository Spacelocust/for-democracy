package model

import (
	"time"

	"gorm.io/gorm"
)

type Session struct {
	gorm.Model
	VerificationKey *string
	AccessToken     string
	ExpiresAt       time.Time
	UserID          uint `gorm:"unique"`
}
