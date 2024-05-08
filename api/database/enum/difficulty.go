package enum

import (
	"database/sql/driver"
	"fmt"
)

type Difficulty string

const (
	Trivial        Difficulty = "trivial"
	Easy           Difficulty = "easy"
	Medium         Difficulty = "medium"
	Challenging    Difficulty = "challenging"
	Hard           Difficulty = "hard"
	Extreme        Difficulty = "extreme"
	SuicideMission Difficulty = "suicide_mission"
	Impossible     Difficulty = "impossible"
	Helldive       Difficulty = "helldive"
)

func (d *Difficulty) Scan(value interface{}) error {
	b, ok := value.([]byte)
	if !ok {
		switch value {
		case Trivial, Easy, Medium, Challenging, Hard, Extreme, SuicideMission, Impossible, Helldive:
			*d = Difficulty(b)
		default:
			return fmt.Errorf("invalid value for Difficulty: %v", value)
		}
	}
	return nil
}

func (d Difficulty) Value() (driver.Value, error) {
	return string(d), nil
}
