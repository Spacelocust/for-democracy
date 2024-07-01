package model

import (
	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type Waypoint struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type Planet struct {
	gorm.Model
	Name          string       `gorm:"not null;unique"`
	MaxHealth     int          `gorm:"not null"`
	Disabled      bool         `gorm:"not null;default:false"`
	PositionX     float64      `gorm:"not null"`
	PositionY     float64      `gorm:"not null"`
	HelldiversID  int          `gorm:"not null"`
	ImageURL      string       `gorm:"not null"`
	BackgroundURL string       `gorm:"not null"`
	InitialOwner  enum.Faction `gorm:"not null;type:faction"`
	Owner         enum.Faction `gorm:"not null;type:faction"`
	Statistic     Statistic
	Waypoints     []Waypoint `gorm:"not null;serializer:json;default:'[]'"`
	Liberation    *Liberation
	Defence       *Defence
	Effects       []Effect `gorm:"many2many:planet_effects;"`
	Group         []Group
	Biome         Biome
	BiomeID       uint
	Sector        Sector
	SectorID      uint
}
