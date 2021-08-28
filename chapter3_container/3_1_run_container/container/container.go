package container

import (
	"github.com/sirupsen/logrus"
	"os"
	"os/exec"
	"syscall"
)

func NewParentProcess(tty bool, command string) *exec.Cmd {
	args := []string{"init", command}
	// 子进程中调用自己，并发送init参数，在子进程中初始化容器资源（自己的init命令！）
	cmd := exec.Command("/proc/self/exe", args...)
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWIPC |
			syscall.CLONE_NEWPID | syscall.CLONE_NEWNS | syscall.CLONE_NEWNET,
	}
	// 如果支持
	if tty {
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
	}
	return cmd
}

// RunContainerInitProcess 在容器中创建初始化进程！（本函数在容器内部，作为第一个进程被执行）
func RunContainerInitProcess(command string, args []string) error {
	// systemd 加入linux之后, mount namespace 就变成 shared by default, 所以你必须显式声明你要这个新的mount namespace独立！
	// Issue：https://github.com/xianlubird/mydocker/issues/41
	err := syscall.Mount("", "/", "", syscall.MS_PRIVATE|syscall.MS_REC, "")
	if err != nil {
		return err
	}

	// 使用 mount 挂载 proc 文件系统（以便后面通过 ps 命令查看当前进程资源）
	// MS_NOEXEC：本文件系统不允许运行其他程序
	// MS_NOSUID：本系统运行程序时，不允许 set-user-id, set-group-id
	// MS_NODEV：mount系统的默认参数
	defaultMountFlags := syscall.MS_NOEXEC | syscall.MS_NOSUID | syscall.MS_NODEV
	err = syscall.Mount("proc", "/proc", "proc", uintptr(defaultMountFlags), "")
	if err != nil {
		return err
	}

	// 完成容器内初始化，并将用户进程运行起来！
	// syscall.Exec 最终调用 execve 系统函数，执行当前 filename 对应程序
	// 并”覆盖“当前进程的镜像、数据和堆栈等信息，包括PID，因此将容器最开始的 init 进程替换掉！
	argv := []string{command}
	if err := syscall.Exec(command, argv, os.Environ()); err != nil {
		logrus.Errorf(err.Error())
	}
	return nil
}
