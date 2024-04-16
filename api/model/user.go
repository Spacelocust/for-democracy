package model

import (
	"github.com/Spacelocust/for-democracy/enum"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	Username string    `gorm:"unique;not null"`
	Password string    `gorm:"not null"`
	Email    string    `gorm:"unique;not null"`
	Role     enum.Role `gorm:"not null"`
}
