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
	b, ok := value.([]byte)
	if !ok {
		switch value.(string) {
		case string(Supply), string(Mission), string(Defensive), string(Offensive):
			*st = StratagemType(b)
		default:
			return fmt.Errorf("invalid value for StratagemType: %v", value)
		}
	}
	return nil
}

func (st StratagemType) Value() (driver.Value, error) {
	return string(st), nil
}
