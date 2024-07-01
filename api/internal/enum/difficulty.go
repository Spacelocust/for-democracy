package enum

import (
	"database/sql/driver"
	"fmt"

	"github.com/go-playground/validator/v10"
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
	str, ok := value.(string)

	if ok {
		switch str {
		case string(Trivial), string(Easy), string(Medium), string(Challenging), string(Hard), string(Extreme), string(SuicideMission), string(Impossible), string(Helldive):
			*d = Difficulty(str)
		default:
			return fmt.Errorf("invalid value for Difficulty: %v", value)
		}
	}

	return nil
}

func (d Difficulty) Value() (driver.Value, error) {
	return string(d), nil
}

func ValidateDifficulty(fl validator.FieldLevel) bool {
	value := fl.Field().Interface().(Difficulty)
	switch value {
	case Trivial, Easy, Medium, Challenging, Hard, Extreme, SuicideMission, Impossible, Helldive:
		return true
	default:
		return false
	}
}
