package colorize

import (
	"github.com/fatih/color"
)

type Colorize interface {
	// Bg returns value with background color
	Bg(value string) string
	// Fg returns value with foreground color
	Fg(value string) string
}

type colorize struct {
	fgColor *color.Color
	bgColor *color.Color
}

var (
	Red   = New(color.FgRed, color.BgHiRed)
	Cyan  = New(color.FgCyan, color.BgHiCyan)
	Blue  = New(color.FgBlue, color.BgHiBlue)
	White = New(color.FgWhite, color.BgWhite)
)

// New returns a new colorize instance
func New(fgColor color.Attribute, bgColor color.Attribute) Colorize {
	return &colorize{fgColor: color.New(fgColor), bgColor: color.New(bgColor)}
}

// Bg returns value with background color
func (c *colorize) Bg(value string) string {
	return c.bgColor.SprintFunc()(value)
}

// Fg returns value with foreground color
func (c *colorize) Fg(value string) string {
	return c.fgColor.SprintFunc()(value)
}
