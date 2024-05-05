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

func (sk *StratagemKeys) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case Up, Right, Down, Left:
			*sk = StratagemKeys(b)
		default:
			return fmt.Errorf("invalid value for StratagemKeys: %v", value)
		}
	}
	return nil
}

func (sk StratagemKeys) Value() (driver.Value, error) {
	return string(sk), nil
}
