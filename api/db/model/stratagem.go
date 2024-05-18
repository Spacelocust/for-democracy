package model

import (
	"github.com/Spacelocust/for-democracy/db/datatype"
	"github.com/Spacelocust/for-democracy/db/enum"
	"gorm.io/gorm"
)

type Stratagem struct {
	gorm.Model
	CodeName          *string
	Name              string `gorm:"not null;unique"`
	UseCount          *int
	UseType           enum.StratagemUseType                  `gorm:"not null"`
	Cooldown          int                                    `gorm:"not null"`
	Activation        int                                    `gorm:"not null"`
	ImageURL          string                                 `gorm:"not null"`
	Type              enum.StratagemType                     `gorm:"not null;type:stratagem_type"`
	Keys              datatype.EnumArray[enum.StratagemKeys] `gorm:"not null;type:text[]"`
	GroupUserMissions []*GroupUserMission                    `gorm:"many2many:group_user_mission_stratagems;"`
}
