package model

import (
	"time"

	"gorm.io/gorm"
)

type TokenFcm struct {
	ID        uint `gorm:"primarykey"`
	CreatedAt time.Time
	UpdatedAt time.Time
	DeletedAt gorm.DeletedAt `gorm:"index"`
	Token     string         `gorm:"unique;not null"`
	UserID    uint
	User      User
}
