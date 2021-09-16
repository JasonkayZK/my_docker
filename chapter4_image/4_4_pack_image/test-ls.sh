############################## Test 1：镜像打包 ##############################
# 宿主机启动一个容器
./my_docker run -it sh
#{"level":"info","msg":"create read-only layer success, path in host: /root/my-docker/busybox/","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"create write layer success, path in host: /root/my-docker/writeLayer","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"create mount point success, dirs: dirs=/root/my-docker/writeLayer:/root/my-docker/busybox, mntUrl: /root/my-docker/mnt/","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"init come on","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 34149","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 34149","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 34149","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 34149","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"command all is sh","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"Current location is /root/my-docker/mnt","time":"2021-09-16T13:15:56Z"}
#{"level":"info","msg":"find cmd absolute path /bin/sh","time":"2021-09-16T13:15:56Z"}

# 宿主机另一个Shell，打包
./my_docker commit my-image
# output tar image: /root/my-docker/my-image.tar

# 查看打包后的镜像：
ll /root/my-docker/
#total 2192
#drwxr-xr-x  6 root root    4096 Sep 16 13:19 ./
#drwx------ 13 root root    4096 Sep 16 13:19 ../
#drwxr-xr-x 12 root root    4096 Sep 15 19:06 busybox/
#-rw-------  1 root root 1464320 Sep 15 19:02 busybox.tar
#drwxr-xr-x 14 root root    4096 Sep 16 13:19 mnt/
#-rw-r--r--  1 root root  749805 Sep 16 13:19 my-image.tar
#drwxr-xr-x  4 root root    4096 Sep 16 09:38 volume/
#drwxr-xr-x  4 root root    4096 Sep 16 13:19 writeLayer/

# 可以看到打包后的文件： `my-image.tar`

# 解压并查看：
mkdir /root/my-docker/my-image && cd /root/my-docker/my-image/
tar -xvf /root/my-docker/my-image.tar

# 查看文件：
ll
#total 60
#drwxr-xr-x 12 root   root     4096 Sep 16 13:19 ./
#drwxr-xr-x  5 root   root     4096 Sep 16 13:22 ../
#drwxr-xr-x  2 root   root    16384 Aug 20 16:25 bin/
#drwxr-xr-x  4 root   root     4096 Sep  7 21:14 dev/
#-rwxr-xr-x  1 root   root        0 Sep  7 21:14 .dockerenv*
#drwxr-xr-x  3 root   root     4096 Sep  7 21:14 etc/
#drwxr-xr-x  2 nobody nogroup  4096 Aug 20 16:25 home/
#drwxr-xr-x  2 root   root     4096 Sep  7 21:14 proc/
#drwx------  2 root   root     4096 Aug 20 16:25 root/
#drwxr-xr-x  2 root   root     4096 Sep  7 21:14 sys/
#drwxrwxrwt  2 root   root     4096 Aug 20 16:25 tmp/
#drwxr-xr-x  3 root   root     4096 Aug 20 16:25 usr/
#drwxr-xr-x  4 root   root     4096 Aug 20 16:25 var/

# 可以看到镜像里面的内容
