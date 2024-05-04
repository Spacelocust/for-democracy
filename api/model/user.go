package model

import (
	"github.com/Spacelocust/for-democracy/enum"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	SteamId    *string `gorm:"unique"`
	Username   string  `gorm:"unique;not null"`
	Password   *string
	AvatarUrl  *string
	Role       enum.Role `gorm:"not null;type:enum('user', 'admin');default:'user'"`
	GroupUsers []GroupUser
}
