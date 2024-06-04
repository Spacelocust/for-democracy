package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type Defence struct {
	gorm.Model
	Players      int `gorm:"not null"`
	StartAt      time.Time
	EndAt        time.Time
	EnemyFaction enum.Faction `gorm:"not null;type:faction"`
	Health       int          `gorm:"not null"`
	MaxHealth    int          `gorm:"not null"`
	HelldiversID int          `gorm:"not null;unique"`
	Planet       *Planet
	PlanetID     uint
}
