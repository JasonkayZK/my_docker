package main

import (
	"log"
	"os"
	"os/exec"
	"syscall"
)

func main() {
	cmd := exec.Command("sh")
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWIPC |
			syscall.CLONE_NEWPID | syscall.CLONE_NEWNS | syscall.CLONE_NEWUSER,
		/*
			以下两种情况，会导致UidMappings/GidMappings中设置了非当前进程所属UID和GID的相关数值：
			1. HostID非本进程所有（与Getuid()和Getgid()不等）
			2. Size大于1 （则肯定包含非当前进程的UID和GID）
			则需要Host机使用Root权限才能正常执行此段代码。

			Issue #3 error about User Namespace：

				https://github.com/xianlubird/mydocker/issues/3
		*/
		UidMappings: []syscall.SysProcIDMap{
			{
				ContainerID: 1,
				HostID:      syscall.Getuid(),
				Size:        1,
			},
		},
		GidMappings: []syscall.SysProcIDMap{
			{
				ContainerID: 1,
				HostID:      syscall.Getgid(),
				Size:        1,
			},
		},
	}

	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Run(); err != nil {
		log.Fatal(err)
	}

	os.Exit(-1)
}
