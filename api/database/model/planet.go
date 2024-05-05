package model

import (
	"gorm.io/gorm"
)

type Planet struct {
	gorm.Model
	Name                 string `gorm:"not null"`
	Health               *int
	MaxHealth            *int
	Players              int                   `gorm:"not null;default:0"`
	Disabled             bool                  `gorm:"not null;default:false"`
	Regeneration         int                   `gorm:"not null;default:0"`
	PositionX            float64               `gorm:"not null"`
	PositionY            float64               `gorm:"not null"`
	HelldiversID         int                   `gorm:"not null"`
	Statistic            Statistic             `gorm:"foreignKey:PlanetID"`
	EnvironmentalEffects []EnvironmentalEffect `gorm:"many2many:planet_environmental_effects;"`
	Biome                Biome
	BiomeID              uint
}
