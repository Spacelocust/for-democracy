package model

import (
	"time"

	"gorm.io/gorm"
)

type Feature struct {
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
	Code      string         `gorm:"primarykey;not null;unique"`
	Enabled   bool           `gorm:"not null;default:true"`
}
