package cmd

import (
	"log"
	"os"

	"github.com/Spacelocust/for-democracy/cmd/server"
	"github.com/urfave/cli/v2"
)

// Entry point for the CLI
func RunCLI() {
	app := &cli.App{
		Commands: []*cli.Command{
			server.StartCmd,
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}
