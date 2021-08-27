package cmd

import (
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/container"
)

var InitCommand = cli.Command{
	Name:  "init",
	Usage: "Init container process run user's process in container. Do not call it outside",
	Action: func(context *cli.Context) error {
		log.Infof("init come on")
		return container.RunContainerInitProcess()
	},
}
