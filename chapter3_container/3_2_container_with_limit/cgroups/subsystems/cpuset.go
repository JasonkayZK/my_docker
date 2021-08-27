package subsystems

import (
	"fmt"
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
	if res.CpuSet != "" {
		err = ioutil.WriteFile(path.Join(subsystemCgroupPath, CpuSetCgroupConfig),
			[]byte(res.CpuSet), utils.DefaultCgroupConfigFilePerm)
		if err != nil {
			return fmt.Errorf("set cgroup cpuset fail %v", err)
		}
	}
	return nil
}

func (c *CpuSetSubSystem) Apply(cgroupPath string, pid int) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}

	err = ioutil.WriteFile(path.Join(subsystemCgroupPath, CgroupConfigPath),
		[]byte(strconv.Itoa(pid)), utils.DefaultCgroupConfigFilePerm)
	if err != nil {
		return fmt.Errorf("set cgroup proc fail %v", err)
	}
	return nil
}

func (c *CpuSetSubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(c.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
