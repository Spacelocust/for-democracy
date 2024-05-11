package model

import (
	"gorm.io/gorm"
)

type Effect struct {
	gorm.Model
	Name        string   `gorm:"not null;unique"`
	Description string   `gorm:"type:text;not null"`
	Planets     []Planet `gorm:"many2many:planet_effects;"`
}
