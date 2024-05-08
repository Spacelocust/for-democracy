package model

import (
	"time"

	"gorm.io/gorm"
)

type Feature struct {
	DeletedAt gorm.DeletedAt `gorm:"index"`
	Code      string         `gorm:"primarykey;not null;unique"`
	Enabled   bool           `gorm:"not null;default:true"`
	UpdatedAt time.Time
	CreatedAt time.Time
}
