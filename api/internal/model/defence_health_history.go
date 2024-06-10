package model

import (
	"gorm.io/gorm"
)

// The liberation health history model is used to store the health history of a liberation to calculate the helldivers planetary control impact
type DefenceHealthHistory struct {
	gorm.Model
	Health    int `gorm:"not null"`
	Defence   *Defence
	DefenceID uint
}
