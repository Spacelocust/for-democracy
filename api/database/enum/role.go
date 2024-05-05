package enum

import (
	"database/sql/driver"
	"fmt"
)

type Role string

const (
	Admin Role = "admin"
	User  Role = "user"
)

func (r *Role) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case Admin, User:
			*r = Role(b)
		default:
			return fmt.Errorf("invalid value for Role: %v", value)
		}
	}
	return nil
}

func (r Role) Value() (driver.Value, error) {
	return string(r), nil
}
