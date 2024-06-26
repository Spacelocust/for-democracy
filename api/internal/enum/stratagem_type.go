package enum

import (
	"database/sql/driver"
	"fmt"
)

type StratagemType string

const (
	Supply    StratagemType = "supply"
	Mission   StratagemType = "mission"
	Defensive StratagemType = "defensive"
	Offensive StratagemType = "offensive"
)

func (st *StratagemType) Scan(value interface{}) error {
	str, ok := value.(string)

	if ok {
		switch value.(string) {
		case string(Supply), string(Mission), string(Defensive), string(Offensive):
			*st = StratagemType(str)
		default:
			return fmt.Errorf("invalid value for StratagemType: %v", value)
		}
	}

	return nil
}

func (st StratagemType) Value() (driver.Value, error) {
	return string(st), nil
}
