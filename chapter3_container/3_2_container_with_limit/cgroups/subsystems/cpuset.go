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
	CpuSetName = `cpuset`

	CpuSetCgroupConfig = "cpuset.cpus"
)

type CpuSetSubSystem struct {
}

func (c *CpuSetSubSystem) Name() string {
	return CpuSetName
}

func (c *CpuSetSubSystem) Set(cgroupPath string, res *ResourceConfig) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return err
	}

	// 如果存在CPU核心数的配置
	configPath := path.Join(subsystemCgroupPath, CpuSetCgroupConfig)
	if res.CpuSet != "" {
		err = ioutil.WriteFile(configPath,
			[]byte(res.CpuSet), utils.DefaultCgroupConfigFilePerm)
		if err != nil {
			return fmt.Errorf("set cgroup cpuset fail %v", err)
		}
	}

	log.Infof("set cpu-set success, file: %s, cpu-set num: %s",
		configPath,
		res.CpuSet,
	)
	return nil
}

func (c *CpuSetSubSystem) Apply(cgroupPath string, pid int) error {
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

	log.Infof("apply cpu-set success, file: %s, pid: %d",
		path.Join(subsystemCgroupPath, CgroupConfigPath),
		pid,
	)
	return nil
}

func (c *CpuSetSubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
