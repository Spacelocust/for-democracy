package model

import (
	"github.com/Spacelocust/for-democracy/internal/enum"
	"github.com/Spacelocust/for-democracy/password"
	"gorm.io/gorm"
)

type User struct {
	gorm.Model
	SteamId    *string `gorm:"unique"`
	Username   string  `gorm:"unique;not null"`
	Password   *string
	AvatarUrl  *string
	Role       enum.Role `gorm:"not null;type:role"`
	TokenFcm   *TokenFcm
	Tokens     []Token
	GroupUsers []GroupUser
}

func (u *User) BeforeCreate(*gorm.DB) error {
	encodedHash, err := password.GenerateFromPassword("admin", password.DefaultHashParams)

	if err != nil {
		return err
	}

	u.Password = &encodedHash

	return nil
}
