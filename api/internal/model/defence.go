package model

import (
	"time"

	"github.com/Spacelocust/for-democracy/internal/enum"
	"gorm.io/gorm"
)

type Defence struct {
	gorm.Model
	Players                int `gorm:"not null"`
	StartAt                time.Time
	EndAt                  time.Time
	EnemyFaction           enum.Faction `gorm:"not null;type:faction"`
	Health                 int          `gorm:"not null"`
	MaxHealth              int          `gorm:"not null"`
	ImpactPerHour          float64      `gorm:"not null;default:0"`
	HelldiversID           int          `gorm:"not null;unique"`
	DefenceHealthHistories []DefenceHealthHistory
	Planet                 *Planet
	PlanetID               uint
}

func (l *Defence) BeforeDelete(tx *gorm.DB) (err error) {
	// Delete DefenceHealthHistory records associated with the Defence
	return tx.Unscoped().Where("defence_id = ?", l.ID).Delete(&DefenceHealthHistory{}).Error
}

func (l *Defence) AfterSave(tx *gorm.DB) (err error) {
	// Delete DefenceHealthHistory records older than 20 minutes to avoid storing too much data
	return tx.Unscoped().Where("created_at < ?", time.Now().Add(-21*time.Minute)).Delete(&DefenceHealthHistory{}).Error
}
