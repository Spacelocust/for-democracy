package model

import "gorm.io/gorm"

type Liberation struct {
	gorm.Model
	Health       int `gorm:"not null"`
	Players      int `gorm:"not null"`
	HelldiversID int `gorm:"not null;unique"`
	PlanetID     uint
}
