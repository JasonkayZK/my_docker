############################## Test 0：导出Busybox官方镜像内容到压缩包 ##############################
# 使用busybox创建镜像
docker run -d busybox:1.34.0 top -b
# 输出：
# 95ef3a4e910428c37fd739d76ee5e68c1771508704f17a319d0e420bcbdfd40b

# 导出压缩包
docker export -o busybox.tar 95ef3a4e9104 # 容器Id

# 解压缩
mkdir -p /root/my-docker/busybox && tar -xvf /root/my-docker/busybox.tar -C /root/my-docker/busybox/

############################## Test 1：命令执行测试 ##############################
./my_docker run -ti -m 100m -- ls -lat /

# 输出如下：
# {"level":"info","msg":"init come on","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 32993","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 32993","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 32993","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 32993","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"command all is ls -lat /","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"Current location is /root/my-docker/busybox","time":"2021-09-14T12:32:33Z"}
# {"level":"info","msg":"find cmd absolute path /bin/ls","time":"2021-09-14T12:32:33Z"}
# total 48
# drwxr-xr-x   12 root     root          4096 Sep 14 12:32 .
# drwxr-xr-x   12 root     root          4096 Sep 14 12:32 ..
# drwxr-xr-x    2 root     root            40 Sep 14 12:32 dev
# dr-xr-xr-x  326 root     root             0 Sep 14 12:32 proc
# -rwxr-xr-x    1 root     root             0 Sep  7 21:14 .dockerenv
# drwxr-xr-x    3 root     root          4096 Sep  7 21:14 etc
# drwxr-xr-x    2 root     root          4096 Sep  7 21:14 sys
# drwxr-xr-x    2 nobody   nobody        4096 Aug 20 16:25 home
# drwxr-xr-x    3 root     root          4096 Aug 20 16:25 usr
# drwxr-xr-x    4 root     root          4096 Aug 20 16:25 var
# drwx------    2 root     root          4096 Aug 20 16:25 root
# drwxrwxrwt    2 root     root          4096 Aug 20 16:25 tmp
# drwxr-xr-x    2 root     root         12288 Aug 20 16:25 bin

# 可以看到，已经将宿主机中的 `/root/my-docker/busybox` 映射至了容器进程中！

############################## Test 2：修改容器中文件 ##############################
./my_docker run -ti -- mkdir /test

# 输出如下：
# {"level":"info","msg":"init come on","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"set cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu.mems: 0","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 33033","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 33033","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 33033","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"apply cpu.mems success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 33033","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"command all is mkdir /test","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"Current location is /root/my-docker/busybox","time":"2021-09-14T12:33:19Z"}
# {"level":"info","msg":"find cmd absolute path /bin/mkdir","time":"2021-09-14T12:33:19Z"}

# 可以看到，命令成功执行，并且在宿主机中的 `/root/my-docker/busybox` 下真正创建了一个`test`目录！
ll /root/my-docker/busybox/

# 输出如下：
# total 60
# drwxr-xr-x 13 root   root     4096 Sep 14 12:33 ./
# drwxr-xr-x  3 root   root     4096 Sep 14 12:32 ../
# drwxr-xr-x  2 root   root    12288 Aug 20 16:25 bin/
# drwxr-xr-x  4 root   root     4096 Sep  7 21:14 dev/
# -rwxr-xr-x  1 root   root        0 Sep  7 21:14 .dockerenv*
# drwxr-xr-x  3 root   root     4096 Sep  7 21:14 etc/
# drwxr-xr-x  2 nobody nogroup  4096 Aug 20 16:25 home/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 proc/
# drwx------  2 root   root     4096 Aug 20 16:25 root/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 sys/
# drwxr-xr-x  2 root   root     4096 Sep 14 12:33 test/
# drwxrwxrwt  2 root   root     4096 Aug 20 16:25 tmp/
# drwxr-xr-x  3 root   root     4096 Aug 20 16:25 usr/
# drwxr-xr-x  4 root   root     4096 Aug 20 16:25 var/

# 在4—2中，将会使用UnionFS，将容器中的修改和宿主机的文件进行隔离！
