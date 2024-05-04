package model

import (
	"github.com/Spacelocust/for-democracy/enum"
	"gorm.io/gorm"
)

type Stratagem struct {
	gorm.Model
	CodeName          *string
	Name              string `gorm:"not null"`
	UseCount          *int
	UseType           enum.StratagemUseType `gorm:"not null;type:enum('self', 'team', 'shared');default:'self'"`
	Cooldown          int                   `gorm:"not null"`
	Activation        int                   `gorm:"not null"`
	ImageURL          string                `gorm:"not null"`
	Type              enum.StratagemType    `gorm:"not null;type:enum('supply', 'mission', 'defensive', 'offensive')"`
	Keys              []enum.StratagemKeys  `gorm:"not null, type:string[]"`
	GroupUserMissions []GroupUserMission    `gorm:"many2many:group_user_mission_stratagems;"`
}
