package model

import (
	"gorm.io/gorm"
)

type GroupUserMission struct {
	gorm.Model
	MissionID   uint
	Mission     Mission
	GroupUserID uint
	GroupUser   GroupUser
	Stratagems  []Stratagem `gorm:"many2many:group_user_mission_stratagems;"`
}
