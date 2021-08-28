# sleep一秒钟是让配置先生效，然后再在子进程中进行初始化，然后执行用户自定义命令！

############################## Test 3：宿主机cpu测试 ##############################
./my_docker run -ti -cpushare 1 -- stress --vm-bytes 200m --vm-keep -m 1
# {"level":"info","msg":"init come on","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"cmdArray [stress --vm-bytes 200m --vm-keep -m 1]","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"sleep 1 second, wait for resource config!","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 256m","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 1","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 11563","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 11563","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 11563","time":"2021-08-28T18:49:13Z"}
# {"level":"info","msg":"find cmd absolute path /usr/bin/stress","time":"2021-08-28T18:49:14Z"}
# stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd

# 宿主机
stress --vm-bytes 200m --vm-keep -m 1 &
top
# top - 18:51:24 up  2:36,  2 users,  load average: 1.93, 1.21, 0.72
# Tasks: 261 total,   3 running, 258 sleeping,   0 stopped,   0 zombie
# %Cpu(s): 25.2 us,  0.3 sy,  0.0 ni, 74.5 id,  0.0 wa,  0.0 hi,  0.1 si,  0.0 st
# MiB Mem :  15985.9 total,  12352.0 free,   2510.8 used,   1123.2 buff/cache
# MiB Swap:  12288.0 total,  12287.8 free,      0.2 used.  13171.9 avail Mem
#
#    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
#  11574 root      20   0  208660 204992    336 R 100.0   1.3   2:04.49 stress
#  11570 root      20   0  208660 204936    272 R  98.7   1.3   2:07.95 stress

# 可以看到，容器中的时间片的确比外部的要少（效果并不明显）

# 注：试验结束记得使用htop清理多余的stress进程！！！！！！！
