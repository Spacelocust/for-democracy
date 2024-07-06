package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type Group struct {
	ID          uint `gorm:"primarykey"`
	CreatedAt   time.Time
	UpdatedAt   time.Time
	DeletedAt   gorm.DeletedAt  `gorm:"index"`
	Code        string          `gorm:"unique,not null"`
	Name        string          `gorm:"not null"`
	Description *string         `gorm:"type:text"`
	Public      bool            `gorm:"not null"`
	StartAt     time.Time       `gorm:"not null"`
	Difficulty  enum.Difficulty `gorm:"not null;type:difficulty"`
	Missions    []Mission       `gorm:"constraint:OnDelete:CASCADE"`
	GroupUsers  []GroupUser     `gorm:"constraint:OnDelete:CASCADE"`
	Planet      Planet
	PlanetID    uint
}

func (g *Group) BeforeDelete(tx *gorm.DB) (err error) {
	// Delete all Missions associated with the Group
	if err := tx.Unscoped().Where("group_id = ?", g.ID).Delete(&Mission{}).Error; err != nil {
		return err
	}

	// Delete all GroupUser records associated with the Group
	if err := tx.Unscoped().Where("group_id = ?", g.ID).Delete(&GroupUser{}).Error; err != nil {
		return err
	}

	return nil
}
