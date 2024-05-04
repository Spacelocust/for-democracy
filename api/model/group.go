package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/enum"
	"gorm.io/gorm"
)

type Group struct {
	gorm.Model
	Code        string          `gorm:"unique,not null"`
	Name        string          `gorm:"not null"`
	Description *string         `gorm:"type:text"`
	Public      bool            `gorm:"not null;default:true"`
	StartAt     time.Time       `gorm:"not null"`
	Difficulty  enum.Difficulty `gorm:"not null;type:enum('trivial', 'easy', 'medium', 'challenging', 'hard', 'extreme', 'suicide_mission', 'impossible', 'helldive')"`
	Missions    []Mission
}
