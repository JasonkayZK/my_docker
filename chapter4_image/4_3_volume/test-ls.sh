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


################################ Test 1：挂载本地目录`/root/my-docker/volume:/containerVolume` ################################
./my_docker run -it -v /root/my-docker/volume:/containerVolume sh
# {"level":"info","msg":"create read-only layer success, path in host: /root/my-docker/busybox/","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"create write layer success, path in host: /root/my-docker/writeLayer","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"create mount point success, dirs: dirs=/root/my-docker/writeLayer:/root/my-docker/busybox, mntUrl: /root/my-docker/mnt/","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"mount user volume at: /root/my-docker/mnt/, volume pair: [/root/my-docker/volume /containerVolume]","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"init come on","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 85431","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 85431","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 85431","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 85431","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"command all is sh","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"Current location is /root/my-docker/mnt","time":"2021-09-15T16:51:11Z"}
# {"level":"info","msg":"find cmd absolute path /bin/sh","time":"2021-09-15T16:51:11Z"}
# / #

# 从上面的日志可以看到容器的创建和初始化顺序：
# 1、根据镜像【压缩文件】创建read-only层；
# 2、创建写入write层；
# 3、挂载用户自定义volume层；
# 4、初始化进程启动：限制 cpu-set、memory等各种资源；
# 5、找到并执行用户初始化命令；

# 同时，可以看到：容器进程多了一个 `containerVolume` 目录：
ls
# bin              dev              home             root             tmp              var
# containerVolume  etc              proc             sys              usr

################################ Test 2：修改容器中用户挂载的文件 ################################

# 在容器的进程中创建文件：
echo -e "hello world" >> /containerVolume/test.txt
ls containerVolume/
# test.txt

cat containerVolume/test.txt
# hello world

# 在宿主机中查看容器中的文件：
pwd
# /root/my-docker

ll volume/
# total 20
# drwxr-xr-x 4 root root 4096 Sep 15 17:36 ./
# drwxr-xr-x 6 root root 4096 Sep 15 16:51 ../
# -rw-r--r-- 1 root root   12 Sep 15 17:36 test.txt
# -r--r--r-- 1 root root    0 Sep 15 16:51 .wh..wh.aufs
# drwx------ 2 root root 4096 Sep 15 16:51 .wh..wh.orph/
# drwx------ 2 root root 4096 Sep 15 16:51 .wh..wh.plnk/

cat volume/test.txt
# hello world

# 可以看到，在宿主机的映射目录也创建的对应的文件！

################################ Test 3：退出容器后用户挂载的文件仍保留 ################################
# 退出容器shell进程：
exit
# {"level":"info","msg":"remove mount point with volume success: /root/my-docker/mnt/","time":"2021-09-15T21:45:09Z"}
# {"level":"info","msg":"remove write layer success: /root/my-docker/writeLayer","time":"2021-09-15T21:45:09Z"}

# 查看宿主机中的 /root/my-docker 目录：
ll
# total 1448
# drwxr-xr-x  4 root root    4096 Sep 15 21:45 ./
# drwx------ 13 root root    4096 Sep 15 21:47 ../
# drwxr-xr-x 12 root root    4096 Sep 15 19:06 busybox/
# -rw-------  1 root root 1464320 Sep 15 19:02 busybox.tar
# drwxr-xr-x  4 root root    4096 Sep 15 21:44 volume/

# 可以看到，volume目录没有被删除，同时，内容保持不变：
cat volume/test.txt
# hello world


################################ Test 4：重新挂载宿主机存在的目录到容器中 ################################
# 将宿主机的 `/root/my-docker/volume` 挂载到容器的 `/containerVolume` 目录下
./my_docker run -it -v /root/my-docker/volume:/containerVolume sh

# {"level":"info","msg":"create read-only layer success, path in host: /root/my-docker/busybox/","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"create write layer success, path in host: /root/my-docker/writeLayer","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"create mount point success, dirs: dirs=/root/my-docker/writeLayer:/root/my-docker/busybox, mntUrl: /root/my-docker/mnt/","time":"2021-09-15T21:50:54Z"}
# {"level":"error","msg":"mkdir parent dir /root/my-docker/volume err: mkdir /root/my-docker/volume: file exists","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"mount user volume at: /root/my-docker/mnt/, volume pair: [/root/my-docker/volume /containerVolume]","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"init come on","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 6574","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 6574","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 6574","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 6574","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"command all is sh","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"Current location is /root/my-docker/mnt","time":"2021-09-15T21:50:54Z"}
# {"level":"info","msg":"find cmd absolute path /bin/sh","time":"2021-09-15T21:50:54Z"}
# / #

# 查看容器文件系统根目录的内容：
ls
# bin              dev              home             root             tmp              var
# containerVolume  etc              proc             sys              usr
cat containerVolume/test.txt
# hello world

# 发现已经存在 `containerVolume` 目录，并且已经包含内容！

# 向 `containerVolume/test-again.txt` 写入一行数据
echo -e "hello world, again" >> /containerVolume/test-again.txt
ls containerVolume/
# test-again.txt  test.txt
cat containerVolume/test-again.txt
# hello world, again

# 查看宿主机目录：
ll volume/
# total 24
# drwxr-xr-x 4 root root 4096 Sep 16 09:38 ./
# drwxr-xr-x 6 root root 4096 Sep 15 21:50 ../
# -rw-r--r-- 1 root root   19 Sep 16 09:38 test-again.txt
# -rw-r--r-- 1 root root   12 Sep 15 21:49 test.txt
# -r--r--r-- 1 root root    0 Sep 15 19:06 .wh..wh.aufs
# drwx------ 2 root root 4096 Sep 15 19:06 .wh..wh.orph/
# drwx------ 2 root root 4096 Sep 15 19:06 .wh..wh.plnk/
cat volume/test-again.txt
# hello world, again
