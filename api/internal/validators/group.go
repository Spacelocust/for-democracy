package validators

import "github.com/Spacelocust/for-democracy/internal/enum"

type Group struct {
	Name        string          `json:"name" validate:"required"`
	Description *string         `json:"description"`
	Public      *bool           `json:"public" validate:"required,boolean"`
	StartAt     string          `json:"startAt" validate:"required,datetime,gte_datetime=now" default:"2024-08-02 15:04:05"`
	Difficulty  enum.Difficulty `json:"difficulty" validate:"required,difficulty"`
	PlanetID    uint            `json:"planetId" validate:"required"`
}

type GroupUpdate struct {
	Name        string          `json:"name" validate:"required"`
	Description *string         `json:"description"`
	Public      *bool           `json:"public" validate:"required,boolean"`
	StartAt     string          `json:"startAt" validate:"required,datetime,gte_datetime=now" default:"2024-08-02 15:04:05"`
	Difficulty  enum.Difficulty `json:"difficulty" validate:"required,difficulty"`
}

type GroupCode struct {
	Code string `json:"code" validate:"required"`
}
