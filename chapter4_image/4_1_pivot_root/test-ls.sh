# 解压缩
mkdir -p /root/busybox && tar -xvf busybox.tar -C /root/busybox/

############################## Test 1：命令执行测试 ##############################
./my_docker run -ti -m 100m -- ls -lat /

# 输出如下：
# {"level":"info","msg":"init come on","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu-set num: 0","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 3993","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 3993","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 3993","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 3993","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"command all is ls -lat /","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"Current location is /root/busybox","time":"2021-09-13T19:57:35Z"}
# {"level":"info","msg":"find cmd absolute path /bin/ls","time":"2021-09-13T19:57:35Z"}
# total 48
# drwxr-xr-x   12 root     root          4096 Sep 13 19:57 .
# drwxr-xr-x   12 root     root          4096 Sep 13 19:57 ..
# drwxr-xr-x    2 root     root            40 Sep 13 19:57 dev
# dr-xr-xr-x  326 root     root             0 Sep 13 19:57 proc
# -rwxr-xr-x    1 root     root             0 Sep  7 21:14 .dockerenv
# drwxr-xr-x    3 root     root          4096 Sep  7 21:14 etc
# drwxr-xr-x    2 root     root          4096 Sep  7 21:14 sys
# drwxr-xr-x    2 nobody   nobody        4096 Aug 20 16:25 home
# drwxr-xr-x    3 root     root          4096 Aug 20 16:25 usr
# drwxr-xr-x    4 root     root          4096 Aug 20 16:25 var
# drwx------    2 root     root          4096 Aug 20 16:25 root
# drwxrwxrwt    2 root     root          4096 Aug 20 16:25 tmp
# drwxr-xr-x    2 root     root         12288 Aug 20 16:25 bin

# 可以看到，已经将宿主机中的 `/root/busybox` 映射至了容器进程中！

############################## Test 2：修改容器中文件 ##############################

./my_docker run -ti -- mkdir /test

# 输出如下：
# {"level":"info","msg":"init come on","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.mems, cpu-set num: 0","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 4121","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 4121","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 4121","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 4121","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"command all is mkdir /test","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"Current location is /root/busybox","time":"2021-09-13T19:59:27Z"}
# {"level":"info","msg":"find cmd absolute path /bin/mkdir","time":"2021-09-13T19:59:27Z"}

# 可以看到，命令成功执行，并且在宿主机中的 `/root/busybox` 下真正创建了一个`test`目录！
ll /root/busybox/

# 输出如下：
# total 60
# drwxr-xr-x 13 root   root     4096 Sep 13 19:59 ./
# drwx------ 13 root   root     4096 Sep 13 20:01 ../
# drwxr-xr-x  2 root   root    12288 Aug 20 16:25 bin/
# drwxr-xr-x  4 root   root     4096 Sep  7 21:14 dev/
# -rwxr-xr-x  1 root   root        0 Sep  7 21:14 .dockerenv*
# drwxr-xr-x  3 root   root     4096 Sep  7 21:14 etc/
# drwxr-xr-x  2 nobody nogroup  4096 Aug 20 16:25 home/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 proc/
# drwx------  2 root   root     4096 Aug 20 16:25 root/
# drwxr-xr-x  2 root   root     4096 Sep  7 21:14 sys/
# drwxr-xr-x  2 root   root     4096 Sep 13 19:59 test/
# drwxrwxrwt  2 root   root     4096 Aug 20 16:25 tmp/
# drwxr-xr-x  3 root   root     4096 Aug 20 16:25 usr/
# drwxr-xr-x  4 root   root     4096 Aug 20 16:25 var/

# 在4—2中，将会使用UnionFS，将容器中的修改和宿主机的文件进行隔离！
