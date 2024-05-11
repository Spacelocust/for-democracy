package model

import (
	"gorm.io/gorm"
)

type Effect struct {
	gorm.Model
	Name        string   `gorm:"not null"`
	Description *string  `gorm:"type:text"`
	Planets     []Planet `gorm:"many2many:planet_effects;"`
}
