############################## Test 1：创建Detach容器 ##############################
my_docker run -d top

# {"level":"info","msg":"create read-only layer success, path in host: /root/my-docker/busybox/","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"create write layer success, path in host: /root/my-docker/writeLayer","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"create mount point success, dirs: dirs=/root/my-docker/writeLayer:/root/my-docker/busybox, mntUrl: /root/my-docker/mnt/","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 41875","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 41875","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 41875","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 41875","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"command all is top","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"remove mount point with volume success: /root/my-docker/mnt/","time":"2021-09-16T17:38:34Z"}
# {"level":"info","msg":"remove write layer success: /root/my-docker/writeLayer","time":"2021-09-16T17:38:34Z"}

# 随后，宿主进程就退出，top 进程由 PID 为1的init进程接管：
ps -ef
# UID          PID    PPID  C STIME TTY          TIME CMD
# root       41875       1  0 17:38 pts/0    00:00:00 top

# 可以看到PPID为1，说明虽然 my-docker 主进程退出了，但是容器进程仍然存在，并被 PID 为1的 init进程接管；


# 清除top进程
kill -9 41875
