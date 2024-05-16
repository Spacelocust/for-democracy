package model

import (
	"time"

	"gorm.io/gorm"
)

type Defence struct {
	gorm.Model
	Health          int `gorm:"not null"`
	StartAt         time.Time
	EndAt           time.Time
	EnnemyHealth    int `gorm:"not null"`
	EnnemyMaxHealth int `gorm:"not null"`
	HelldiversID    int `gorm:"not null;unique"`
	PlanetID        uint
}
