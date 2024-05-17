package model

import (
	"github.com/Spacelocust/for-democracy/db/enum"
	"gorm.io/gorm"
)

type Planet struct {
	gorm.Model
	Name         string       `gorm:"not null;unique"`
	MaxHealth    int          `gorm:"not null"`
	Disabled     bool         `gorm:"not null;default:false"`
	Regeneration int          `gorm:"not null;default:0"`
	PositionX    float64      `gorm:"not null"`
	PositionY    float64      `gorm:"not null"`
	HelldiversID int          `gorm:"not null"`
	ImageURL     string       `gorm:"not null"`
	InitialOwner enum.Faction `gorm:"not null;type:faction"`
	Owner        enum.Faction `gorm:"not null;type:faction"`
	Statistic    Statistic
	Liberation   *Liberation
	Defence      *Defence
	Effects      []Effect `gorm:"many2many:planet_effects;"`
	Biome        Biome
	BiomeID      uint
}
