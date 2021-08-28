package subsystems

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"io/ioutil"
	"my_docker/cgroups/utils"
	"os"
	"path"
	"strconv"
)

var (
	CpuName = `cpu`

	CpuCgroupConfig = "cpu.shares"
)

type CpuSubSystem struct {
}

func (c *CpuSubSystem) Name() string {
	return CpuName
}

func (c *CpuSubSystem) Set(cgroupPath string, res *ResourceConfig) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return err
	}

	configPath := path.Join(subsystemCgroupPath, CpuCgroupConfig)
	// 如果存在CPU时间片的配置
	if res.CpuShare != "" {
		err = ioutil.WriteFile(configPath,
			[]byte(res.CpuShare), utils.DefaultCgroupConfigFilePerm)
		if err != nil {
			return fmt.Errorf("set cgroup cpu share fail %v", err)
		}
	}

	log.Infof("set cpu-share success, file: %s, cpu-share: %s",
		configPath,
		res.CpuShare,
	)
	return nil
}

func (c *CpuSubSystem) Apply(cgroupPath string, pid int) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}

	configPath := path.Join(subsystemCgroupPath, CgroupConfigPath)
	err = ioutil.WriteFile(configPath,
		[]byte(strconv.Itoa(pid)), utils.DefaultCgroupConfigFilePerm)
	if err != nil {
		return fmt.Errorf("set cgroup proc fail %v", err)
	}

	log.Infof("apply cpu-share success, file: %s, pid: %d",
		path.Join(subsystemCgroupPath, CgroupConfigPath),
		pid,
	)
	return nil
}

func (c *CpuSubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
