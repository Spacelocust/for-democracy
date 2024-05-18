package cmd

import (
	"log"
	"os"

	"github.com/urfave/cli/v2"
)

// Entry point for the CLI
func RunCLI() {
	app := &cli.App{
		Commands: []*cli.Command{
			exampleCmd,
			serverCmd,
			gatherCmd,
		},
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}