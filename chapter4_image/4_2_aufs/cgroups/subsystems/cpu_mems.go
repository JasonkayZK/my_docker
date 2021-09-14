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
	CpuMemsCgroupConfig = "cpuset.mems"
)

type CpuMemsSubSystem struct {
}

func (c *CpuMemsSubSystem) Name() string {
	return CpuSetName
}

func (c *CpuMemsSubSystem) Set(cgroupPath string, res *ResourceConfig) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return err
	}

	configPath := path.Join(subsystemCgroupPath, CpuMemsCgroupConfig)

	if res.CpuMems == "" {
		res.CpuMems = "0"
	}
	err = ioutil.WriteFile(configPath,
		[]byte(res.CpuMems), utils.DefaultCgroupConfigFilePerm)
	if err != nil {
		return fmt.Errorf("set cgroup cpu.mems fail %v", err)
	}

	log.Infof("set cpu.mems success, file: %s, cpu.mems: %s",
		configPath,
		res.CpuMems,
	)
	return nil
}

func (c *CpuMemsSubSystem) Apply(cgroupPath string, pid int) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}

	configPath := path.Join(subsystemCgroupPath, CgroupConfigPath)
	err = ioutil.WriteFile(configPath,
		[]byte(strconv.Itoa(pid)), utils.DefaultCgroupConfigFilePerm)
	if err != nil {
		return fmt.Errorf("set cpuset cgroup proc fail %v", err)
	}

	log.Infof("apply cpu.mems success, file: %s, pid: %d",
		path.Join(subsystemCgroupPath, CgroupConfigPath),
		pid,
	)
	return nil
}

func (c *CpuMemsSubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
