package cmd

import (
	"github.com/Spacelocust/for-democracy/internal/cron"
	"github.com/urfave/cli/v2"
)

// ExampleCmd is an example command for the API serve
var cronCmd = &cli.Command{
	Name:    "cron",
	Usage:   "Cron job for the API serve",
	Aliases: []string{},
	Action: func(c *cli.Context) error {
		cron.StartCron()
		return nil
	},
}
