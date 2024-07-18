package cmd

import (
	"fmt"
	"log"

	"github.com/Spacelocust/for-democracy/internal/database"
	"github.com/Spacelocust/for-democracy/internal/fixtures"
	"github.com/urfave/cli/v2"
)

var featureFixturesCmd = &cli.Command{
	Name:    "featureFixtures",
	Usage:   "Feature fixtures",
	Aliases: []string{"ff"},
	Action: func(ff *cli.Context) error {
		fmt.Println("Loading feature fixtures")

		newFeatureFixture := fixtures.NewFeatureFixture(database.New())

		if health := newFeatureFixture.Db.Health(); len(health) < 1 {
			log.Fatal("Database is not healthy")

			return nil
		}

		newFeatureFixture.LoadFixtures()

		return nil
	},
}