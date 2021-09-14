package container

import (
	"fmt"
	log "github.com/sirupsen/logrus"
	"io/ioutil"
	"my_docker/utils"
	"path/filepath"
	"strings"

	"os"
	"os/exec"
	"syscall"
)

var (
	MntUrl = "/root/my-docker/mnt/" // 宿主机挂载目录

	RootUrl = "/root/my-docker/" // 宿主机根目录

	WriteLayerName = "writeLayer"
)

func NewParentProcess(tty bool) (*exec.Cmd, *os.File) {
	readPipe, writePipe, err := utils.NewPipe()
	if err != nil {
		log.Errorf("New pipe error %v", err)
		return nil, nil
	}

	// 子进程中调用自己，并发送init参数，在子进程中初始化容器资源（自己的init命令！）
	cmd := exec.Command("/proc/self/exe", "init")
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWIPC |
			syscall.CLONE_NEWPID | syscall.CLONE_NEWNS | syscall.CLONE_NEWNET,
	}
	// 如果支持tty
	if tty {
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}

	cmd.ExtraFiles = []*os.File{readPipe}

	// 创建挂载的工作目录
	err = NewWorkSpace(RootUrl, MntUrl)
	if err != nil {
		return nil, nil
	}

	// 容器进程中的初始化工作目录
	cmd.Dir = MntUrl

	return cmd, writePipe
}

// RunContainerInitProcess 在容器中创建初始化进程！（本函数在容器内部，作为第一个进程被执行）
func RunContainerInitProcess() error {

	// 从无名管道中获取用户的参数（从WritePipe过来！）
	cmdArray := readUserCommand()
	if cmdArray == nil || len(cmdArray) == 0 {
		return fmt.Errorf("run container get user command error, cmdArray is nil")
	}

	// 将文件系统重新挂载，并隔离
	err := setUpMount()
	if err != nil {
		return err
	}

	// 查询命令的绝对路径，此时用户可以不再输入绝对路径！
	absPath, err := exec.LookPath(cmdArray[0])
	if err != nil {
		log.Errorf("Exec loop path error %v", err)
		return err
	}
	log.Infof("find cmd absolute path %s", absPath)

	// 完成容器内初始化，并将用户进程运行起来！
	// syscall.Exec 最终调用 execve 系统函数，执行当前 filename 对应程序
	// 并”覆盖“当前进程的镜像、数据和堆栈等信息，包括PID，因此将容器最开始的 init 进程替换掉！
	if err = syscall.Exec(absPath, cmdArray, os.Environ()); err != nil {
		log.Errorf("init container err: %v", err.Error())
	}
	return nil
}

// NewWorkSpace 在宿主机创建容器中对应的AUFS工作目录【Root Workspace】
func NewWorkSpace(rootUrl, mntUrl string) error {
	// 创建AUFS只读层【镜像文件】
	err := createReadOnlyLayer(rootUrl)
	if err != nil {
		return err
	}

	// 创建AUFS写入层【容器文件】
	err = createWriteLayer(rootUrl)
	if err != nil {
		return err
	}

	// 创建AUFS挂载点
	err = createMountPoint(rootUrl, mntUrl)
	if err != nil {
		return err
	}

	return nil
}

// 创建AUFS只读层【镜像文件】
// 创建AUFS只读层只需要将tar文件【镜像源文件】解压缩到指定位置
func createReadOnlyLayer(rootUrl string) error {
	busyboxUrl, busyboxTarUrl := rootUrl+"busybox/", rootUrl+"busybox.tar"
	exist, err := utils.PathExists(busyboxUrl)
	if err != nil {
		log.Infof("check path exist err, dir: %s, err: %v", busyboxUrl, err)
	}
	if exist == false {
		if err := os.Mkdir(busyboxUrl, 0777); err != nil {
			log.Errorf("mkdir dir %s error. %v", busyboxUrl, err)
		}
		if _, err := exec.Command("tar", "-xvf", busyboxTarUrl, "-C", busyboxUrl).CombinedOutput(); err != nil {
			log.Errorf("untar dir %s error %v", busyboxUrl, err)
		}
	}

	log.Infof("create read-only layer success, path in host: %s", busyboxUrl)

	return nil
}

// 创建AUFS写入层【容器文件】
func createWriteLayer(rootUrl string) error {
	writeUrl := rootUrl + WriteLayerName
	if err := os.Mkdir(writeUrl, 0777); err != nil {
		log.Errorf("mkdir dir %s error. %v", writeUrl, err)
	}

	log.Infof("create write layer success, path in host: %s", writeUrl)

	return nil
}

// 创建AUFS挂载点
func createMountPoint(rootUrl, mntUrl string) error {
	// 创建挂载点目录
	if err := os.Mkdir(mntUrl, 0777); err != nil {
		log.Errorf("Mkdir dir %s error. %v", mntUrl, err)
	}

	// 通过mount命令挂载
	dirs := "dirs=" + rootUrl + "writeLayer:" + rootUrl + "busybox"
	cmd := exec.Command("mount", "-t", "aufs", "-o", dirs, "none", mntUrl)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Errorf("%v", err)
	}

	log.Infof("create mount point success, dirs: %s, mntUrl: %s", dirs, mntUrl)

	return nil
}

// DeleteWorkspace 退出容器后，删除AUFS工作目录
func DeleteWorkspace(rootUrl, mntUrl string) error {
	err := deleteMountPoint(mntUrl)
	if err != nil {
		return err
	}

	err = deleteWriteLayer(rootUrl)
	if err != nil {
		return err
	}

	return nil
}

// 删除写入层挂载点
func deleteMountPoint(mntUrl string) error {
	cmd := exec.Command("umount", mntUrl)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Errorf("%v", err)
	}
	if err := os.RemoveAll(mntUrl); err != nil {
		log.Errorf("remove dir %s error %v", mntUrl, err)
	}

	log.Infof("remove mount point success: %s", mntUrl)

	return nil
}

// 删除写入层
func deleteWriteLayer(rootUrl string) error {
	writeUrl := rootUrl + WriteLayerName
	if err := os.RemoveAll(writeUrl); err != nil {
		log.Errorf("remove dir %s error %v", writeUrl, err)
	}

	log.Infof("remove write layer success: %s", writeUrl)

	return nil
}

// 从无名管道中获取输入
func readUserCommand() []string {
	// 这里用3号文件描述符是因为，我们只创建了一个管道流，而默认是0、1、2（标准输入+输出，错误输出）
	pipe := os.NewFile(uintptr(3), "pipe")
	msg, err := ioutil.ReadAll(pipe)
	if err != nil {
		log.Errorf("init read pipe error %v", err)
		return nil
	}
	msgStr := string(msg)
	return strings.Split(msgStr, " ")
}

// 将容器进程中的文件系统重新挂载
func setUpMount() error {

	// systemd 加入linux之后, mount namespace 就变成 shared by default, 所以你必须显式声明你要这个新的mount namespace独立！
	// Issue：https://github.com/xianlubird/mydocker/issues/41
	err := syscall.Mount("", "/", "", syscall.MS_PRIVATE|syscall.MS_REC, "")
	if err != nil {
		return err
	}

	pwd, err := os.Getwd()
	if err != nil {
		log.Errorf("Get current location error %v", err)
		return err
	}

	log.Infof("Current location is %s", pwd)

	// 为了使当前root的老 root 和新 root 不在同一个文件系统下，我们把root重新mount了一次
	//  bind mount是把相同的内容换了一个挂载点的挂载方法
	err = pivotRoot(pwd)

	// 使用 mount 挂载 proc 文件系统（以便后面通过 ps 命令查看当前进程资源）
	// MS_NOEXEC：本文件系统不允许运行其他程序
	// MS_NOSUID：本系统运行程序时，不允许 set-user-id, set-group-id
	// MS_NODEV：mount系统的默认参数
	defaultMountFlags := syscall.MS_NOEXEC | syscall.MS_NOSUID | syscall.MS_NODEV
	err = syscall.Mount("proc", "/proc", "proc", uintptr(defaultMountFlags), "")
	if err != nil {
		return err
	}

	// tmpfs 是一种基于内存的文件系统，可以使用 RAM 或者 swap 分区来存储；
	err = syscall.Mount("tmpfs", "/dev", "tmpfs", syscall.MS_NOSUID|syscall.MS_STRICTATIME, "mode=755")
	if err != nil {
		return err
	}

	return nil
}

// 为了使当前root的老 root 和新 root 不在同一个文件系统下，我们把root重新mount了一次
func pivotRoot(root string) error {
	// bind mount是把相同的内容换了一个挂载点的挂载方法
	if err := syscall.Mount(root, root, "bind", syscall.MS_BIND|syscall.MS_REC, ""); err != nil {
		log.Errorf("mount rootfs to itself error: %v", err)
		return fmt.Errorf("mount rootfs to itself error: %v", err)
	}

	// 创建 rootfs/.pivot_root 存储 old_root
	pivotDir := filepath.Join(root, ".pivot_root")
	if err := os.Mkdir(pivotDir, 0777); err != nil {
		return err
	}

	// pivot_root 到新的rootfs, 现在老的 old_root 是挂载在rootfs/.pivot_root
	// 挂载点现在依然可以在mount命令中看到
	if err := syscall.PivotRoot(root, pivotDir); err != nil {
		return fmt.Errorf("pivot_root %v", err)
	}

	// 修改当前的工作目录到根目录
	if err := syscall.Chdir("/"); err != nil {
		return fmt.Errorf("chdir / %v", err)
	}

	pivotDir = filepath.Join("/", ".pivot_root")

	// umount rootfs/.pivot_root
	if err := syscall.Unmount(pivotDir, syscall.MNT_DETACH); err != nil {
		return fmt.Errorf("unmount pivot_root dir %v", err)
	}

	// 删除临时文件夹
	return os.Remove(pivotDir)
}
