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
