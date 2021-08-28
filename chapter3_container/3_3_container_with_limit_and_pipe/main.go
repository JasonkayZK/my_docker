package main

import (
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/cmd"
	"os"
)

const usage = `my-docker is a simple container runtime implementation.
			   The purpose of this project is to learn how docker works and how to write a docker by ourselves
			   Enjoy it, just for fun.`

func main() {
	app := cli.NewApp()
	app.Name = "my-docker"
	app.Usage = usage

	app.Commands = []cli.Command{
		cmd.InitCommand,
		cmd.RunCommand,
	}

	app.Before = func(context *cli.Context) error {
		// Log as JSON instead of the default ASCII formatter.
		log.SetFormatter(&log.JSONFormatter{})
		log.SetOutput(os.Stdout)
		return nil
	}

	if err := app.Run(os.Args); err != nil {
		log.Fatal(err)
	}
}
