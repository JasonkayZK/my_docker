############################## Test 0：数据准备 ##############################
# 解压缩：将 `busybox.tar` 放在 `/root/my-docker` 目录
pwd
# /root/my-docker

ll
# total 1444
# drwxr-xr-x  3 root root    4096 Sep 14 20:43 ./
# drwx------ 13 root root    4096 Sep 14 20:54 ../
# drwxr-xr-x 12 root root    4096 Sep 14 15:03 busybox/
# -rw-------  1 root root 1464320 Sep 14 12:30 busybox.tar

############################## Test 1：命令执行测试 ##############################
./my_docker run -ti -- sh

# 输出结果：
# {"level":"info","msg":"create read-only layer success, path in host: /root/my-docker/busybox/","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"create write layer success, path in host: /root/my-docker/writeLayer","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"create mount point success, dirs: dirs=/root/my-docker/writeLayer:/root/my-docker/busybox, mntUrl: /root/my-docker/mnt/","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"init come on","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 48654","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 48654","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 48654","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 48654","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"command all is sh","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"Current location is /root/my-docker/mnt","time":"2021-09-14T20:55:42Z"}
# {"level":"info","msg":"find cmd absolute path /bin/sh","time":"2021-09-14T20:55:42Z"}
# / #

# 在宿主机中查看 `/root/my-docker` 目录：
ll
# total 1452
# drwxr-xr-x  5 root root    4096 Sep 14 20:55 ./
# drwx------ 13 root root    4096 Sep 14 20:57 ../
# drwxr-xr-x 12 root root    4096 Sep 14 15:03 busybox/
# -rw-------  1 root root 1464320 Sep 14 12:30 busybox.tar
# drwxr-xr-x 14 root root    4096 Sep 14 20:55 mnt/
# drwxr-xr-x  4 root root    4096 Sep 14 20:55 writeLayer/

############################## Test 2：在容器进程修改【创建】文件 ##############################
# 容器进程执行：
touch /tmp/text.txt

# 在宿主机中查看 `/root/my-docker` 目录：
ll busybox/
# 查看宿主机中的镜像层：
# total 56
# drwxr-xr-x 12 root   root     4096 Sep 14 15:03 ./
# drwxr-xr-x  5 root   root     4096 Sep 14 20:55 ../
# drwxr-xr-x  2 root   root    12288 Aug 20 16:25 bin/
# drwxr-xr-x  4 root   root     4096 Sep  7 21:14 dev/
# -rwxr-xr-x  1 root   root        0 Sep  7 21:14 .dockerenv*
# drwxr-xr-x  3 root   root     4096 Sep  7 21:14 etc/
# drwxr-xr-x  2 nobody nogroup  4096 Aug 20 16:25 home/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 proc/
# drwx------  2 root   root     4096 Aug 20 16:25 root/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 sys/
# drwxrwxrwt  2 root   root     4096 Aug 20 16:25 tmp/
# drwxr-xr-x  3 root   root     4096 Aug 20 16:25 usr/
# drwxr-xr-x  4 root   root     4096 Aug 20 16:25 var/
# 可以看到镜像没有变化！

# 宿主机中的写入层：
ll writeLayer/
# total 24
# drwxr-xr-x 6 root root 4096 Sep 14 20:59 ./
# drwxr-xr-x 5 root root 4096 Sep 14 20:55 ../
# drwx------ 2 root root 4096 Sep 14 20:59 root/
# drwxrwxrwt 2 root root 4096 Sep 14 20:59 tmp/
# -r--r--r-- 1 root root    0 Sep 14 20:55 .wh..wh.aufs
# drwx------ 2 root root 4096 Sep 14 20:55 .wh..wh.orph/
# drwx------ 2 root root 4096 Sep 14 20:55 .wh..wh.plnk/
ll writeLayer/tmp/
# total 8
# drwxrwxrwt 2 root root 4096 Sep 14 20:59 ./
# drwxr-xr-x 6 root root 4096 Sep 14 20:59 ../
# -rw-r--r-- 1 root root    0 Sep 14 20:59 text.txt
# 可以看到，写入层真正写入了这些修改！


############################## Test 3：退出容器删除写入层文件 ##############################
# 容器进程退出shell
# / # exit
# {"level":"info","msg":"remove mount point success: /root/my-docker/mnt/","time":"2021-09-14T21:09:25Z"}
# {"level":"info","msg":"remove write layer success: /root/my-docker/writeLayer","time":"2021-09-14T21:09:25Z"}

# 再次查看宿主机中的写入层：
ll
# total 1444
# drwxr-xr-x  3 root root    4096 Sep 14 21:09 ./
# drwx------ 13 root root    4096 Sep 14 21:09 ../
# drwxr-xr-x 12 root root    4096 Sep 14 15:03 busybox/
# -rw-------  1 root root 1464320 Sep 14 12:30 busybox.tar

# 可以看到，写入层已经被删除了，而镜像层【busybox/】仍然保留！

# 下一节，我们将会引入持久化层！
