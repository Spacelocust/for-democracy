package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/db/enum"
	"gorm.io/gorm"
)

type Group struct {
	gorm.Model
	Code        string          `gorm:"unique,not null"`
	Name        string          `gorm:"not null"`
	Description *string         `gorm:"type:text"`
	Public      bool            `gorm:"not null;default:true"`
	StartAt     time.Time       `gorm:"not null"`
	Difficulty  enum.Difficulty `gorm:"not null;type:difficulty"`
	Missions    []Mission
}
