package enum

import (
	"database/sql/driver"
	"fmt"
)

type StratagemKeys string

const (
	Up    StratagemKeys = "up"
	Right StratagemKeys = "right"
	Down  StratagemKeys = "down"
	Left  StratagemKeys = "left"
)

func (stratagemKey *StratagemKeys) Scan(value interface{}) error {
	if value == nil {
		return nil
	}

	switch value {
	case "up":
		*stratagemKey = Up
	case "right":
		*stratagemKey = Right
	case "down":
		*stratagemKey = Down
	case "left":
		*stratagemKey = Left
	default:
		return fmt.Errorf("invalid value for StratagemKeys: %v", value)
	}

	return nil
}

func (stratagemKey StratagemKeys) Value() (driver.Value, error) {
	return string(stratagemKey), nil
}
