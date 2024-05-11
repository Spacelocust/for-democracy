package model

import (
	"gorm.io/gorm"
)

type Biome struct {
	gorm.Model
	Name        string `gorm:"not null;unique"`
	Description string `gorm:"type:text;not null"`
	Planets     []Planet
}
