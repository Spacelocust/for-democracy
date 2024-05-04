package model

import (
	"gorm.io/gorm"
)

type Biome struct {
	gorm.Model
	Name        string  `gorm:"not null"`
	Description *string `gorm:"type:text"`
	Planets     []Planet
}
