package validators

import (
	"github.com/Spacelocust/for-democracy/internal/enum"
)

type Mission struct {
	Name           string               `json:"name" validate:"required"`
	Instructions   *string              `json:"instructions" validate:"omitempty"`
	ObjectiveTypes []enum.ObjectiveType `json:"objectiveTypes" validate:"required,dive,objectiveType"`
	GroupID        uint
}
