package cmd

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/cgroups"
	"my_docker/cgroups/subsystems"
	"my_docker/container"
	"os"
)

var (
	defaultCgroupPath = "mydocker-cgroup"
)

var RunCommand = cli.Command{
	Name: "run",
	Usage: `Create a container with namespace and cgroups limit
			my-docker run -ti [command]`,
	Flags: []cli.Flag{
		cli.BoolFlag{
			Name:  "ti",
			Usage: "enable tty",
		},
		cli.BoolFlag{
			Name:  "it",
			Usage: "enable tty",
		},
		cli.StringFlag{
			Name:  "m",
			Usage: "memory limit",
		},
		cli.StringFlag{
			Name:  "cpushare",
			Usage: "cpushare limit",
		},
		cli.StringFlag{
			Name:  "cpuset",
			Usage: "cpuset limit",
		},
	},
	Action: func(context *cli.Context) error {
		// Step 1：用户初始化命令校验
		if len(context.Args()) < 1 {
			return fmt.Errorf("missing container command")
		}

		// Step 2：获取用户命令行命令
		// Step 2.1：从Context中获取容器内初始化命令
		var cmdArray []string
		for _, arg := range context.Args() {
			cmdArray = append(cmdArray, arg)
		}

		// Step 2.2：从Context中获取容器配置相关命令
		tty := context.Bool("ti") || context.Bool("it") // tty参数
		resourceConfig := getResourceConfig(context) // 容器资源限制参数

		run(tty, cmdArray, resourceConfig)
		return nil
	},
}

func run(tty bool, cmdArray []string, res *subsystems.ResourceConfig) {
	parent := container.NewParentProcess(tty, cmdArray)
	if err := parent.Start(); err != nil {
		log.Error(err)
	}

	cgroupManager := cgroups.NewCgroupManager(defaultCgroupPath)
	defer func(cgroupManager *cgroups.CgroupManager) {
		err := cgroupManager.Destroy()
		if err != nil {
			log.Error(err)
		}
	}(cgroupManager)

	err := cgroupManager.Set(res)
	if err != nil {
		goto FASTEND
	}
	err = cgroupManager.Apply(parent.Process.Pid)
	if err != nil {
		goto FASTEND
	}

	err = parent.Wait()
	if err != nil {
		goto FASTEND
	}

FASTEND:
	if err != nil {
		log.Error(err)
	}

	os.Exit(-1)
}

func getResourceConfig(context *cli.Context) *subsystems.ResourceConfig {
	var (
		memoryLimit = `256m`
		cpuset = `1`
		cpuShare = `512`
	)

	if context.String("m") != "" {
		memoryLimit = context.String("m")
	}
	if context.String("cpuset") != "" {
		cpuset = context.String("cpuset")
	}
	if context.String("cpushare") != "" {
		cpuShare = context.String("cpushare")
	}

	return &subsystems.ResourceConfig{
		MemoryLimit: memoryLimit,
		CpuSet:      cpuset,
		CpuShare:    cpuShare,
	}
}
