package model

import (
	"fmt"

	"gorm.io/gorm"
)

type GroupUserMission struct {
	gorm.Model
	MissionID   uint
	GroupUserID uint
	GroupUser   GroupUser
	Stratagems  []*Stratagem `gorm:"many2many:group_user_mission_stratagems;constraint:OnDelete:CASCADE"`
}

func (gum *GroupUserMission) BeforeDelete(tx *gorm.DB) (err error) {
	// Delete all Stratagem records associated with the GroupUserMission
	if err := tx.Table("group_user_mission_stratagems").Where("group_user_mission_id = ?", gum.ID).Delete(nil).Error; err != nil {
		fmt.Println(err.Error())
		return err
	}

	return nil
}
