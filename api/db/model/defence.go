package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/db/enum"
	"gorm.io/gorm"
)

type Defence struct {
	gorm.Model
	Health         int `gorm:"not null"`
	Players        int `gorm:"not null"`
	StartAt        time.Time
	EndAt          time.Time
	EnemyFaction   enum.Faction `gorm:"not null;type:faction"`
	EnemyHealth    int          `gorm:"not null"`
	EnemyMaxHealth int          `gorm:"not null"`
	HelldiversID   int          `gorm:"not null;unique"`
	Planet         *Planet
	PlanetID       uint
}
