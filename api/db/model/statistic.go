package model

import (
	"time"

	"gorm.io/gorm"
)

type Statistic struct {
	PlanetID           uint `gorm:"primarykey"`
	CreatedAt          time.Time
	UpdatedAt          time.Time
	DeletedAt          gorm.DeletedAt `gorm:"index"`
	MissionsWon        int            `gorm:"not null;default:0"`
	MissionTime        int            `gorm:"not null;default:0"`
	BugKills           int            `gorm:"not null;default:0"`
	AutomatonKills     int            `gorm:"not null;default:0"`
	IlluminateKills    int            `gorm:"not null;default:0"`
	BulletsFired       int            `gorm:"not null;default:0"`
	BulletsHit         int            `gorm:"not null;default:0"`
	TimePlayed         int            `gorm:"not null;default:0"`
	Deaths             int            `gorm:"not null;default:0"`
	Revives            int            `gorm:"not null;default:0"`
	FriendlyKills      int            `gorm:"not null;default:0"`
	MissionSuccessRate int            `gorm:"not null;default:0"`
	Accuracy           int            `gorm:"not null;default:0"`
}
