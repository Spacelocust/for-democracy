package enum

import (
	"database/sql/driver"
	"fmt"
)

type StratagemUseType string

const (
	Self   StratagemUseType = "self"
	Team   StratagemUseType = "team"
	Shared StratagemUseType = "shared"
)

func (st *StratagemUseType) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case Self, Team, Shared:
			*st = StratagemUseType(b)
		default:
			return fmt.Errorf("invalid value for StratagemUseType: %v", value)
		}
	}
	return nil
}

func (st StratagemUseType) Value() (driver.Value, error) {
	return string(st), nil
}
