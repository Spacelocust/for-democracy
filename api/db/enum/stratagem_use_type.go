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
	str, ok := value.(string)

	if ok {
		switch value.(string) {
		case string(Self), string(Team), string(Shared):
			*st = StratagemUseType(str)
		default:
			return fmt.Errorf("invalid value for StratagemUseType: %v", value)
		}
	}

	return nil
}

func (st StratagemUseType) Value() (driver.Value, error) {
	return string(st), nil
}
