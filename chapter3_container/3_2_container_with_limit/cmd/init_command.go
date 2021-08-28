package cmd

import (
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/container"
	"time"
)

var InitCommand = cli.Command{
	Name:  "init",
	Usage: "Init container process run user's process in container. Do not call it outside",
	Action: func(context *cli.Context) error {
		log.Infof("init come on")
		cmdArray := context.Args()
		log.Infof("cmdArray %s", cmdArray)

		log.Infof("sleep 1 second, wait for resource config!")
		time.Sleep(time.Second * 1)

		err := container.RunContainerInitProcess(cmdArray)
		return err
	},
}
