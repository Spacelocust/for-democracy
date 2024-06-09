package model

import (
	"time"

	"gorm.io/gorm"
)

type Liberation struct {
	gorm.Model
	Health                    int     `gorm:"not null"`
	Players                   int     `gorm:"not null"`
	RegenerationPerHour       float64 `gorm:"not null"`
	ImpactPerHour             float64 `gorm:"not null;default:0.0"`
	HelldiversID              int     `gorm:"not null;unique"`
	LiberationHealthHistories []LiberationHealthHistory
	Planet                    *Planet
	PlanetID                  uint
}

func (l *Liberation) BeforeDelete(tx *gorm.DB) (err error) {
	// Delete LiberationHealthHistory records associated with the Liberation
	return tx.Unscoped().Where("liberation_id = ?", l.ID).Delete(&LiberationHealthHistory{}).Error
}

func (l *Liberation) AfterSave(tx *gorm.DB) (err error) {
	// Delete LiberationHealthHistory records older than 20 minutes to avoid storing too much data
	return tx.Unscoped().Where("created_at < ?", time.Now().Add(-21*time.Minute)).Delete(&LiberationHealthHistory{}).Error
}
