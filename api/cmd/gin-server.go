package cmd

import (
	"fmt"

	"github.com/Spacelocust/for-democracy/internal/server"
	"github.com/urfave/cli/v2"
)

var ginCmd = &cli.Command{
	Name:    "gin-server",
	Usage:   "Start the server",
	Aliases: []string{"gs"},
	Action: func(c *cli.Context) error {
		server := server.NewServer()

		err := server.ListenAndServe()
		if err != nil {
			panic(fmt.Sprintf("cannot start server: %s", err))
		}

		return nil
	},
}
