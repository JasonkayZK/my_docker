package cmd

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"io/ioutil"
	"my_docker/container"
	"os"
	"text/tabwriter"
)

var ListCommand = cli.Command{
	Name:  "ps",
	Usage: "list all the containers",
	Action: func(context *cli.Context) error {
		err := ListContainers()
		if err != nil {
			return err
		}
		return nil
	},
}

func ListContainers() error {
	dirURL := fmt.Sprintf(container.DefaultInfoLocation, "")
	dirURL = dirURL[:len(dirURL)-1]
	files, err := ioutil.ReadDir(dirURL)
	if err != nil {
		log.Errorf("read dir %s err: %v", dirURL, err)
		return err
	}

	var containers []*container.ContainerInfo
	for _, file := range files {
		tmpContainer, err := container.GetContainerInfo(file.Name())
		if err != nil {
			log.Errorf("get container info error %v", err)
			continue
		}
		containers = append(containers, tmpContainer)
	}

	w := tabwriter.NewWriter(os.Stdout, 12, 1, 3, ' ', 0)
	_, err = fmt.Fprint(w, "ID\tNAME\tPID\tSTATUS\tCOMMAND\tCREATED\n")
	if err != nil {
		log.Errorf("print container info err: %v", err)
		return err
	}
	for _, item := range containers {
		_, err = fmt.Fprintf(w, "%s\t%s\t%s\t%s\t%s\t%s\n",
			item.Id,
			item.Name,
			item.Pid,
			item.Status,
			item.Command,
			item.CreatedTime)
		if err != nil {
			log.Errorf("print container info err: %v", err)
			return err
		}
	}
	if err = w.Flush(); err != nil {
		log.Errorf("flush error %v", err)
		return err
	}

	return nil
}
