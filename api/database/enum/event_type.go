package enum

import (
	"database/sql/driver"
	"fmt"
)

type EventType string

const (
	Defence    EventType = "defence"
	Liberation EventType = "liberation"
)

func (et *EventType) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case Defence, Liberation:
			*et = EventType(b)
		default:
			return fmt.Errorf("invalid value for EventType: %v", value)
		}
	}
	return nil
}

func (et EventType) Value() (driver.Value, error) {
	return string(et), nil
}
