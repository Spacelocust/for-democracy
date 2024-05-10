package cmd

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/collector"
	"github.com/urfave/cli/v2"
)

// GatherCmd is a command to collector data from the HellHub API
var gatherCmd = &cli.Command{
	Name:    "collector",
	Usage:   "Collect data from the HellHub API and store it in the database",
	Aliases: []string{"c"},
	Action: func(c *cli.Context) error {
		fmt.Println("Collecting data from the HellHub API")
		collector.GatherData()
		return nil
	},
}
