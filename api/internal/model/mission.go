package model

import (
	"github.com/Spacelocust/for-democracy/internal/datatype"
	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type Mission struct {
	gorm.Model
	Name              string                                 `gorm:"not null"`
	Instructions      *string                                `gorm:"type:text"`
	ObjectiveTypes    datatype.EnumArray[enum.ObjectiveType] `gorm:"not null;type:text[]"`
	GroupID           uint
	GroupUserMissions []GroupUserMission `gorm:"constraint:OnDelete:CASCADE"`
}

func (m *Mission) BeforeDelete(tx *gorm.DB) (err error) {
	// Delete all GroupUserMission records associated with the Mission
	return tx.Unscoped().Where("mission_id = ?", m.ID).Delete(&GroupUserMission{}).Error
}

// Returns the objectives of the mission
func (m *Mission) GetObjectives() (map[enum.ObjectiveType]Objective, error) {
	var objectives = make(map[enum.ObjectiveType]Objective, len(m.ObjectiveTypes))

	for _, objectiveType := range m.ObjectiveTypes {
		objective, err := GetObjective(objectiveType)

		if err != nil {
			return nil, err
		}

		objectives[objectiveType] = objective
	}

	return objectives, nil
}
