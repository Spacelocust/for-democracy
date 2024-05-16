package model

import (
	"gorm.io/gorm"
)

type Planet struct {
	gorm.Model
	Name         string  `gorm:"not null;unique"`
	Health       int     `gorm:"not null"`
	MaxHealth    int     `gorm:"not null"`
	Players      int     `gorm:"not null;default:0"`
	Disabled     bool    `gorm:"not null;default:false"`
	Regeneration int     `gorm:"not null;default:0"`
	PositionX    float64 `gorm:"not null"`
	PositionY    float64 `gorm:"not null"`
	HelldiversID int     `gorm:"not null"`
	ImageURL     string  `gorm:"not null"`
	// InitialOwner         enum.Faction `gorm:"not null;type:faction"`
	// Owner                enum.Faction `gorm:"not null;type:faction"`
	Statistic  Statistic
	Liberation *Liberation `gorm:"constraint:OnDelete:SET NULL;default:null"`
	Defence    *Defence    `gorm:"constraint:OnDelete:SET NULL;default:null"`
	Effects    []Effect    `gorm:"many2many:planet_effects;"`
	Biome      Biome
	BiomeID    uint
}
