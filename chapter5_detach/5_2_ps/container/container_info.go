package container

import (
	"encoding/json"
	"fmt"
	log "github.com/sirupsen/logrus"
	"io/fs"
	"io/ioutil"
	"my_docker/cgroups/subsystems"
	"my_docker/utils"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

var (
	/* 容器状态 */
	Running = "running"
	Stop    = "stopped"
	Exit    = "exited"

	DefaultInfoLocation = "/var/run/my-docker/%s/"
	ConfigName          = "config.json"

	ContainerIdLength                 = 16
	DefaultConfigFilePerm fs.FileMode = 0622
)

type CGroupsInfo struct {
	Cpu    string `json:"cpu"`
	CpuSet string `json:"cpu_set"`
	Memory string `json:"memory"`
}

type ContainerInfo struct {
	Pid          string       `json:"pid"`           // 容器的init进程在宿主机上的 PID
	Id           string       `json:"id"`            // 容器Id
	Name         string       `json:"name"`          // 容器名
	Command      string       `json:"command"`       // 容器内init运行命令
	CreatedTime  string       `json:"createTime"`    // 创建时间
	Status       string       `json:"status"`        // 容器的状态
	CGroupsInfos *CGroupsInfo `json:"cgroups_infos"` // 容器资源限制信息
	VolumeInfos  []string     `json:"volume_infos"`  // 容器数据卷挂载
}

// RecordContainerInfo 向文件中记录容器信息
func RecordContainerInfo(containerPID int, commandArray []string, res *subsystems.ResourceConfig, volumeUrls []string,
	containerName string) (string, error) {

	id := utils.RandStringBytes(ContainerIdLength)
	createTime := time.Now().Format(utils.DateFormat)
	commands := strings.Join(commandArray, " ")
	if containerName == "" {
		containerName = id
	}

	containerInfo := &ContainerInfo{
		Id:          id,
		Pid:         strconv.Itoa(containerPID),
		Command:     commands,
		CreatedTime: createTime,
		Status:      Running,
		Name:        containerName,
		CGroupsInfos: &CGroupsInfo{
			Cpu:    res.CpuShare,
			CpuSet: res.CpuSet,
			Memory: res.MemoryLimit,
		},
		VolumeInfos: []string{
			strings.Join(volumeUrls, ":"),
		},
	}

	jsonBytes, err := json.Marshal(containerInfo)
	if err != nil {
		log.Errorf("marshal container info error %v", err)
		return "", err
	}

	dirUrl := fmt.Sprintf(DefaultInfoLocation, containerName)
	if err := os.MkdirAll(dirUrl, DefaultConfigFilePerm); err != nil {
		log.Errorf("Mkdir error %s error %v", dirUrl, err)
		return "", err
	}

	fileName := filepath.Join(dirUrl, ConfigName)
	file, err := os.Create(fileName)
	if err != nil {
		log.Errorf("Create file %s error %v", fileName, err)
		return "", err
	}
	defer func(file *os.File) {
		err := file.Close()
		if err != nil {
			log.Errorf("close file err: %v", err)
		}
	}(file)

	if _, err = file.WriteString(string(jsonBytes)); err != nil {
		log.Errorf("File write string error %v", err)
		return "", err
	}

	return containerName, nil
}

// GetContainerInfo 获取容器名对应容器信息
func GetContainerInfo(containerName string) (*ContainerInfo, error) {
	configFileDir := filepath.Join(fmt.Sprintf(DefaultInfoLocation, containerName), ConfigName)
	content, err := ioutil.ReadFile(configFileDir)
	if err != nil {
		log.Errorf("Read file %s error %v", configFileDir, err)
		return nil, err
	}

	var containerInfo ContainerInfo
	if err := json.Unmarshal(content, &containerInfo); err != nil {
		log.Errorf("Json unmarshal error %v", err)
		return nil, err
	}

	return &containerInfo, nil
}

// DeleteContainerInfo 删除容器信息
func DeleteContainerInfo(containerId string) error {
	dirURL := fmt.Sprintf(DefaultInfoLocation, containerId)
	if err := os.RemoveAll(dirURL); err != nil {
		log.Errorf("remove dir %s error %v", dirURL, err)
		return err
	}
	return nil
}
