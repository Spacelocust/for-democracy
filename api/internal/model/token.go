package model

import "gorm.io/gorm"

type Token struct {
	gorm.Model
	Token  string
	UserId uint
	User   User
}
