package cmd

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"github.com/urfave/cli"
	"my_docker/cgroups"
	"my_docker/cgroups/subsystems"
	"my_docker/container"
	"os"
	"strings"
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
		cli.StringFlag{
			Name:  "v",
			Usage: "volume",
		},
		cli.BoolFlag{
			Name: "d",
			Usage: "detach container",
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
		detach := context.Bool("d") // detach参数

		// 如果存在 detach，则
		if tty && detach {
			log.Infof("tty & detach both true, tty will be ignored!")
			tty = false
		}

		resourceConfig := getResourceConfig(context)    // 容器资源限制参数

		volume := context.String("v")
		var volumeUrls []string
		if volume != "" {
			volumeUrls = volumeUrlExtract(volume)
			if len(volumeUrls) != 2 || volumeUrls[0] == "" || volumeUrls[1] == "" {
				log.Infof("volume parameter input is incorrect")
				return fmt.Errorf("volume parameter input is incorrect, volume: %s", volume)
			}
		}

		run(tty, cmdArray, resourceConfig, volumeUrls)
		return nil
	},
}

func run(tty bool, comArray []string, res *subsystems.ResourceConfig, volumeUrls []string) {
	parent, writePipe := container.NewParentProcess(tty, volumeUrls)
	if parent == nil {
		log.Errorf("New parent process error")
		return
	}
	err := parent.Start()
	if err != nil {
		log.Error(err)
	}

	cgroupManager := cgroups.NewCgroupManager(defaultCgroupPath)
	defer func(cgroupManager *cgroups.CgroupManager) {
		err := cgroupManager.Destroy()
		if err != nil {
			log.Error(err)
		}
	}(cgroupManager)

	err = cgroupManager.Set(res)
	if err != nil {
		goto FASTEND
	}
	err = cgroupManager.Apply(parent.Process.Pid)
	if err != nil {
		goto FASTEND
	}

	sendInitCommand(comArray, writePipe)

	if tty {
		err = parent.Wait()
		if err != nil {
			log.Errorf("wait parent process err: %v", err)
		}
	}

	// 退出容器后，删除AUFS文件
	err = container.DeleteWorkspace(container.RootUrl, container.MntUrl, volumeUrls)
	if err != nil {
		goto FASTEND
	}

FASTEND:
	if err != nil {
		log.Error(err)
	}

	os.Exit(0)
}

func getResourceConfig(context *cli.Context) *subsystems.ResourceConfig {
	var (
		memoryLimit = `256m`
		cpuset      = `1`
		cpuShare    = `512`
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

// sendInitCommand 向管道中写入用户自定义初始化命令参数
func sendInitCommand(comArray []string, writePipe *os.File) {
	defer func(writePipe *os.File) {
		err := writePipe.Close()
		if err != nil {
			log.Errorf("close write pipe err: %v", err)
		}
	}(writePipe)

	command := strings.Join(comArray, " ")
	log.Infof("command all is %s", command)
	_, err := writePipe.WriteString(command)
	if err != nil {
		log.Errorf("write pipe err: %v", err)
		return
	}
}

// 抽取用户的Volume映射
func volumeUrlExtract(volume string) []string {
	var volumeUrls []string
	volumeUrls = strings.Split(volume, ":")
	for idx, volumeUrl := range volumeUrls {
		volumeUrls[idx] = strings.TrimSpace(volumeUrl)
	}
	return volumeUrls
}
