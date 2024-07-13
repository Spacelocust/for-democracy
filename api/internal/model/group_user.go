package model

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
	GroupID uint
	UserID  uint
	Owner   bool `gorm:"not null;default:false"`
}
