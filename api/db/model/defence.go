package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/db/enum"
	"gorm.io/gorm"
)

type Defence struct {
	gorm.Model
	Health          int `gorm:"not null"`
	StartAt         time.Time
	EndAt           time.Time
	EnnemyFaction   enum.Faction `gorm:"not null;type:faction"`
	EnnemyHealth    int          `gorm:"not null"`
	EnnemyMaxHealth int          `gorm:"not null"`
	HelldiversID    int          `gorm:"not null;unique"`
	PlanetID        uint
}
