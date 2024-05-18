package err

import (
	"fmt"

	"github.com/fatih/color"
)

type Error struct {
	Prefix string
}

var red = color.New(color.FgRed).SprintFunc()

func NewError(prefix string) *Error {
	return &Error{Prefix: prefix}
}

func (e *Error) Error(err error, msg string) error {
	return fmt.Errorf("%s: %s: %w", red(e.Prefix), msg, err)
}
