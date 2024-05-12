package model

import (
	"github.com/Spacelocust/for-democracy/database/enum"
	"github.com/lib/pq"
	"gorm.io/gorm"
)

type Stratagem struct {
	gorm.Model
	CodeName          *string
	Name              string `gorm:"not null;unique"`
	UseCount          *int
	UseType           enum.StratagemUseType `gorm:"not null"`
	Cooldown          int                   `gorm:"not null"`
	Activation        int                   `gorm:"not null"`
	ImageURL          string                `gorm:"not null"`
	Type              enum.StratagemType    `gorm:"not null;type:stratagem_type"`
	Keys              pq.StringArray        `gorm:"not null;type:text[]"`
	GroupUserMissions []*GroupUserMission   `gorm:"many2many:group_user_mission_stratagems;"`
}
