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
	MemoryName = `memory`

	MemoryNameCgroupConfig = "memory.limit_in_bytes"
)

type MemorySubSystem struct {
}

func (m *MemorySubSystem) Name() string {
	return MemoryName
}

func (m *MemorySubSystem) Set(cgroupPath string, res *ResourceConfig) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(m.Name(), cgroupPath)
	if err != nil {
		return err
	}

	// 如果存在内存限制的配置
	if res.CpuSet != "" {
		err = ioutil.WriteFile(path.Join(subsystemCgroupPath, MemoryNameCgroupConfig),
			[]byte(res.CpuSet), utils.DefaultCgroupConfigFilePerm)
		if err != nil {
			return fmt.Errorf("set cgroup cpuset fail %v", err)
		}
	}
	return nil
}

func (m *MemorySubSystem) Apply(cgroupPath string, pid int) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(m.Name(), cgroupPath)
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

func (m *MemorySubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(m.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
