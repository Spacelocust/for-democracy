package model

import (
	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	SteamId    *string `gorm:"unique"`
	Username   string  `gorm:"unique;not null"`
	Password   *string
	AvatarUrl  *string
	Role       enum.Role `gorm:"not null;type:role"`
	Tokens     []Token
	GroupUsers []GroupUser
}
