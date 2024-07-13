package model

import "gorm.io/gorm"

type Feature struct {
	gorm.Model
	Code      string         `gorm:"not null;unique"`
	Enabled   bool           `gorm:"not null;default:true"`
}
