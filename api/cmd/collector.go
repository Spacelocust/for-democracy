package cmd

import (
	"fmt"
	"log"

	"github.com/Spacelocust/for-democracy/internal/collector"
	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/urfave/cli/v2"
)

// GatherCmd is a command to collector data from the HellHub API
var gatherCmd = &cli.Command{
	Name:    "collector",
	Usage:   "Collect data from the HellHub API and store it in the database",
	Aliases: []string{"c"},
	Action: func(c *cli.Context) error {
		fmt.Println("Collecting data from the HellHub API")

		NewCollector := collector.NewCollector(database.New())

		if health := NewCollector.Db.Health(); len(health) < 1 {
			log.Fatal("Database is not healthy")
			return nil
		}

		NewCollector.CollectData()
		return nil
	},
}
