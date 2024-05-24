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
	str, ok := value.(string)

	if ok {
		switch value.(string) {
		case string(Defence), string(Liberation):
			*et = EventType(str)
		default:
			return fmt.Errorf("invalid value for EventType: %v", value)
		}
	}

	return nil
}

func (et EventType) Value() (driver.Value, error) {
	return string(et), nil
}
