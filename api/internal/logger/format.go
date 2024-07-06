package logger

import (
	"strings"

	"golang.org/x/text/cases"
	"golang.org/x/text/language"
)

type TextType string

const (
	uppercase TextType = "uppercase"
	lowercase TextType = "lowercase"
	captilize TextType = "capitalize"
)

type Format struct {
	// textType is the text type
	textType TextType
	// left is the left padding
	left int
	// right is the right padding
	right int
}

const (
	// DefaultPadding is the default padding
	DefaultPadding = 2
	// DefaultTextType is the default text type
	DefaultTextType = uppercase
)

// DefaultFormat is the default format for the output
var DefaultFormat = Format{left: DefaultPadding, right: DefaultPadding, textType: DefaultTextType}

// FormatOutput formats the output with padding
func formatOutput(value string, format ...Format) string {
	// Default format
	fm := DefaultFormat

	// If format is provided then use it
	if len(format) == 0 {
		fm = format[0]
	}

	// Padding the string
	str := strings.Repeat(" ", fm.left) + value + strings.Repeat(" ", fm.right)

	// Switching the text type
	switch fm.textType {
	case lowercase:
		return cases.Lower(language.English).String(str)
	case captilize:
		return cases.Title(language.English).String(str)
	case uppercase:
		return cases.Upper(language.English).String(str)
	default:
		return str
	}
}
