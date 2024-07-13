package model

import (
	"gorm.io/gorm"
)

type GroupUser struct {
	gorm.Model
	GroupID           uint
	User              User
	UserID  	      uint
	Owner      		  bool               `gorm:"not null;default:false"`
	GroupUserMissions []GroupUserMission `gorm:"constraint:OnDelete:CASCADE"`
}

func (gu *GroupUser) BeforeDelete(tx *gorm.DB) (err error) {
    // Delete all GroupUserMission records associated with the GroupUser
    return tx.Unscoped().Where("group_user_id = ?", gu.ID).Delete(&GroupUserMission{}).Error
}
