package model

import (
	"gorm.io/gorm"
)

// The liberation health history model is used to store the health history of a liberation to calculate the helldivers planetary control impact
type LiberationHealthHistory struct {
	gorm.Model
	Health       int `gorm:"not null"`
	Liberation   *Liberation
	LiberationID uint
}

// GetHealthToPercentage returns the health of the liberation as a percentage
func (l *LiberationHealthHistory) GetHealthToPercentage() float64 {
	return float64((1000000-l.Health)*100) / 1000000
}
