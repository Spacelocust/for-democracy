package cmd

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/gather"
	"github.com/urfave/cli/v2"
)

// GatherCmd is a command to gather data from the HellHub API
var gatherCmd = &cli.Command{
	Name:    "gather",
	Usage:   "Gather data from the HellHub API and store it in the database",
	Aliases: []string{"g"},
	Action: func(c *cli.Context) error {
		fmt.Println("Gathering data from the HellHub API")
		gather.GatherData()
		return nil
	},
}
