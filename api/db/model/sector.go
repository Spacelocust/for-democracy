package model

import (
	"gorm.io/gorm"
)

type Sector struct {
	gorm.Model
	HelldiversID int    `gorm:"not null;unique"`
	Name         string `gorm:"not null;unique"`
	Planets      []Planet
}
