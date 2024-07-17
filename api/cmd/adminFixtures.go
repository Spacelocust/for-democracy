package cmd

import (
	"fmt"
	"log"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/fixtures"
	"github.com/urfave/cli/v2"
)

var adminFixturesCmd = &cli.Command{
	Name:    "adminFixtures",
	Usage:   "Admin fixtures",
	Aliases: []string{"af"},
	Action: func(af *cli.Context) error {
		fmt.Println("Collecting data from the HellHub API")

		newAdminFixture := fixtures.NewAdminFixture(database.New())

		if health := newAdminFixture.Db.Health(); len(health) < 1 {
			log.Fatal("Database is not healthy")

			return nil
		}

		newAdminFixture.LoadFixtures()

		return nil
	},
}