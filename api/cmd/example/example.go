package example

import (
	"fmt"

	"github.com/urfave/cli/v2"
)

// ExampleCmd is an example command for the API serve
var ExampleCmd = &cli.Command{
	Name:    "example",
	Usage:   "Example command for the API serve",
	Aliases: []string{"e"},
	Action: func(c *cli.Context) error {
		fmt.Println("hello, this is an example command")
		return nil
	},
}
