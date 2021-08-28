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

	configPath := path.Join(subsystemCgroupPath, MemoryNameCgroupConfig)
	// 如果存在内存限制的配置
	if res.MemoryLimit != "" {
		err = ioutil.WriteFile(configPath,
			[]byte(res.MemoryLimit), utils.DefaultCgroupConfigFilePerm)
		if err != nil {
			return fmt.Errorf("set cgroup cpuset fail %v", err)
		}
	}

	log.Infof("set memory success, file: %s, size: %s",
		configPath,
		res.MemoryLimit,
	)
	return nil
}

func (m *MemorySubSystem) Apply(cgroupPath string, pid int) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(m.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}

	configPath := path.Join(subsystemCgroupPath, CgroupConfigPath)
	err = ioutil.WriteFile(configPath,
		[]byte(strconv.Itoa(pid)), utils.DefaultCgroupConfigFilePerm)
	if err != nil {
		return fmt.Errorf("set cgroup proc fail %v", err)
	}

	log.Infof("apply memory success, file: %s, pid: %d",
		path.Join(subsystemCgroupPath, CgroupConfigPath),
		pid,
	)
	return nil
}

func (m *MemorySubSystem) Remove(cgroupPath string) error {
	subsystemCgroupPath, err := utils.GetCgroupPath(m.Name(), cgroupPath)
	if err != nil {
		return fmt.Errorf("get cgroup %s error: %v", cgroupPath, err)
	}
	return os.RemoveAll(subsystemCgroupPath)
}
