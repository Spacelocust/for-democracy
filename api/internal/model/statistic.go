package model

import (
	"gorm.io/gorm"
)

type Statistic struct {
	gorm.Model
	Planet             *Planet
	PlanetID           uint
	HelldiversID       int     `gorm:"not null;unique"`
	MissionsWon        int     `gorm:"not null;default:0"`
	MissionsLost       int     `gorm:"not null;default:0"`
	MissionTime        int     `gorm:"not null;default:0"`
	BugKills           int     `gorm:"not null;default:0"`
	AutomatonKills     int     `gorm:"not null;default:0"`
	IlluminateKills    int     `gorm:"not null;default:0"`
	BulletsFired       int     `gorm:"not null;default:0"`
	BulletsHit         int     `gorm:"not null;default:0"`
	TimePlayed         int     `gorm:"not null;default:0"`
	Deaths             int     `gorm:"not null;default:0"`
	Revives            int     `gorm:"not null;default:0"`
	FriendlyKills      int     `gorm:"not null;default:0"`
	MissionSuccessRate float64 `gorm:"not null;default:0"`
	Accuracy           float64 `gorm:"not null;default:0"`
}
