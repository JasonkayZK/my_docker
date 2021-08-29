package main

import (
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path"
	"strconv"
	"syscall"
)

const (
	// 挂载了memory subsystem的hierarchy的根目录位置
	cgroupMemoryHierarchyMount = "/sys/fs/cgroup/memory"
)

func main() {
	// 容器进程
	if os.Args[0] == "/proc/self/exe" {
		fmt.Printf("current pid %d\n", syscall.Getpid())

		cmd := exec.Command("sh", "-c", `stress --vm-bytes 200m --vm-keep -m 1`)
		cmd.SysProcAttr = &syscall.SysProcAttr{
		}
		cmd.Stdin = os.Stdin
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		if err := cmd.Run(); err != nil {
			fmt.Println(err)
			os.Exit(1)
		}
	}

	cmd := exec.Command("/proc/self/exe")
	cmd.SysProcAttr = &syscall.SysProcAttr{
		Cloneflags: syscall.CLONE_NEWUTS | syscall.CLONE_NEWPID | syscall.CLONE_NEWNS,
	}
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	if err := cmd.Start(); err != nil {
		fmt.Println("ERROR", err)
		os.Exit(1)
	}
	// 得到fork出来进程映射在外部命名空间的pid
	fmt.Printf("%v", cmd.Process.Pid)

	// 在系统默认创建挂载了memory subsystem的hierarchy上创建cgroup
	_ = os.Mkdir(path.Join(cgroupMemoryHierarchyMount, "testmemorylimit"), 0755)
	// 将容器进程加入这个cgroup中
	_ = ioutil.WriteFile(path.Join(cgroupMemoryHierarchyMount, "testmemorylimit", "tasks"), []byte(strconv.Itoa(cmd.Process.Pid)), 0644)
	// 限制cgroup中进程使用
	_ = ioutil.WriteFile(path.Join(cgroupMemoryHierarchyMount, "testmemorylimit", "memory.limit_in_bytes"), []byte("100m"), 0644)

	_, _ = cmd.Process.Wait()
}
