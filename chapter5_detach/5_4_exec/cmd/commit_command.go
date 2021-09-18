package cmd

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/container"
	"os/exec"
)

var CommitCommand = cli.Command{
	Name:  "commit",
	Usage: "commit a container into image",
	Action: func(context *cli.Context) error {
		if len(context.Args()) < 1 {
			return fmt.Errorf("missing container name")
		}
		imageName := context.Args().Get(0)
		if len(imageName) <= 0 {
			return fmt.Errorf("missing container name")
		}
		err := commitContainer(imageName)
		if err != nil {
			return err
		}
		return nil
	},
}

func commitContainer(imageName string) error {
	imageTar := container.RootUrl + imageName + ".tar"

	fmt.Printf("output tar image: %s\n", imageTar)

	_, err := exec.Command("tar", "-czf", imageTar, "-C", container.MntUrl, ".").CombinedOutput()
	if err != nil {
		log.Errorf("tar folder %s error %v", container.MntUrl, err)
		return err
	}
	return nil
}
