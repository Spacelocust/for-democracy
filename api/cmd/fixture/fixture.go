package fixture

import (
	"fmt"

	"github.com/urfave/cli/v2"
)

// loadFixtures loads fixtures into the database
func loadFixtures() {
	//TODO implement
	fmt.Println("Loading fixtures")
}

// LoadCmd is the CLI command for loading fixtures into the database
var LoadCmd = &cli.Command{
	Name:    "fixture",
	Usage:   "Load fixtures into the database",
	Aliases: []string{"f"},
	Action: func(c *cli.Context) error {
		loadFixtures()
		return nil
	},
}
