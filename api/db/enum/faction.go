package enum

import (
	"database/sql/driver"
	"fmt"
)

type Faction string

const (
	Humans      Faction = "humans"
	Terminids   Faction = "terminids"
	Automatons  Faction = "automatons"
	Illuminates Faction = "illuminates"
)

func (f *Faction) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value.(string) {
		case string(Humans), string(Terminids), string(Automatons), string(Illuminates):
			*f = Faction(b)
		default:
			return fmt.Errorf("invalid value for Faction: %v", value)
		}
	}
	return nil
}

func (f Faction) Value() (driver.Value, error) {
	return string(f), nil
}
