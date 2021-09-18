     package utils

import (
	"bufio"
	"fmt"
	log "github.com/sirupsen/logrus"
	"os"
	"path"
	"strings"
)

var (
	DefaultCgroupFilePerm os.FileMode = 0755

	DefaultCgroupConfigFilePerm os.FileMode = 0755
)

// FindCgroupMountPoint 查询对应subsystem在当前进程中的挂载点路径
// /proc/self/mountinfo 文件格式：
// 43 35 0:37 / /sys/fs/cgroup/memory rw,nosuid,nodev,noexec,relatime shared:18 - cgroup cgroup rw,memory
// 查找最后一部分的逗号分隔字段，如：memory
func FindCgroupMountPoint(subsystem string) string {
	// 打开当前进程挂载文件（后面会查询信息）
	f, err := os.Open("/proc/self/mountinfo")
	if err != nil {
		return ""
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {
			log.Error(err)
		}
	}(f)

	scanner := bufio.NewScanner(f)
	for scanner.Scan() {
		content := scanner.Text()
		fields := strings.Split(content, " ")
		for _, opt := range strings.Split(fields[len(fields)-1], ",") {
			if opt == subsystem {
				return fields[4]
			}
		}
	}
	if err := scanner.Err(); err != nil {
		log.Error(err)
		return ""
	}
	return ""
}

// GetCgroupPath 获取当前进程中指定cgroup对应的路径
func GetCgroupPath(subsystem string, cgroupPath string) (string, error) {
	cgroupRoot := FindCgroupMountPoint(subsystem)

	// 查询文件是否已经存在
	_, err := os.Stat(path.Join(cgroupRoot, cgroupPath))
	if err != nil {
		// 非文件不存在错误，返回错误
		if !os.IsNotExist(err) {
			return "", fmt.Errorf("cgroup path error %v", err)
		} else { // 如果是文件不存在错误，创建
			if err := os.Mkdir(path.Join(cgroupRoot, cgroupPath), DefaultCgroupFilePerm); err != nil {
				return "", fmt.Errorf("error create cgroup %v", err)
			}
		}
	}

	return path.Join(cgroupRoot, cgroupPath), nil
}
