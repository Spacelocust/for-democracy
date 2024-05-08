package model

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
	GroupID uint
	Group   Group
	UserID  uint
	User    User
	Owner   bool `gorm:"not null;default:false"`
}
