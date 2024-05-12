package model

import (
	"gorm.io/gorm"
)

type Planet struct {
	gorm.Model
	Name                 string    `gorm:"not null"`
	Health               int       `gorm:"not null"`
	MaxHealth            int       `gorm:"not null"`
	Players              int       `gorm:"not null;default:0"`
	Disabled             bool      `gorm:"not null;default:false"`
	Regeneration         int       `gorm:"not null;default:0"`
	PositionX            float64   `gorm:"not null"`
	PositionY            float64   `gorm:"not null"`
	HelldiversID         int       `gorm:"not null"`
	Statistic            Statistic `gorm:"foreignKey:PlanetID"`
	EnvironmentalEffects []Effect  `gorm:"many2many:planet_effects;"`
	Biome                Biome
	BiomeID              uint
}
