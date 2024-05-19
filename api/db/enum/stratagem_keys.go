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
	str, ok := value.(string)

	if ok {
		switch value.(string) {
		case string(Up), string(Right), string(Down), string(Left):
			*sk = StratagemKeys(str)
		default:
			return fmt.Errorf("invalid value for StratagemKeys: %v", value)
		}
	}

	return nil
}

func (sk StratagemKeys) Value() (driver.Value, error) {
	return string(sk), nil
}
