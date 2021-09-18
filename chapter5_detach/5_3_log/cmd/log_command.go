package cmd

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"io/ioutil"
	"my_docker/container"
	"os"
)

var LogCommand = cli.Command{
	Name: "logs",
	Usage: "print logs of a container",
	Action: func(context *cli.Context) error {
		if len(context.Args()) < 1 {
			return fmt.Errorf("container name required")
		}
		containerName := context.Args().Get(0)
		err := showContainerLog(containerName)
		if err != nil {
			return err
		}
		return nil
	},
}

func showContainerLog(containerName string) error {
	dirURL := fmt.Sprintf(container.DefaultInfoLocation, containerName)
	logFileLocation := dirURL + container.ContainerLogFile
	file, err := os.Open(logFileLocation)
	if err != nil {
		log.Errorf("log container open file %s error %v", logFileLocation, err)
		return err
	}
	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			log.Errorf("close log file err: %v", err)
		}
	}(file)
	content, err := ioutil.ReadAll(file)
	if err != nil {
		log.Errorf("read container log file %s error %v", logFileLocation, err)
		return err
	}
	_, err = fmt.Fprint(os.Stdout, string(content))
	if err != nil {
		return err
	}

	return nil
}
