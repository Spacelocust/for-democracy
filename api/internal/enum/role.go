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
	str, ok := value.(string)

	if ok {
		switch value.(string) {
		case string(Admin), string(User):
			*r = Role(str)
		default:
			return fmt.Errorf("invalid value for Role: %v", value)
		}
	}

	return nil
}

func (r Role) Value() (driver.Value, error) {
	return string(r), nil
}
