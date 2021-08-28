############################## Test 2：宿主机内存测试 ##############################

./my_docker run -ti -m 100m -- stress --vm-bytes 200m --vm-keep -m 1
# {"level":"info","msg":"init come on","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 13976","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 13976","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 13976","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"command all is stress --vm-bytes 200m --vm-keep -m 1","time":"2021-08-28T19:28:07Z"}
# {"level":"info","msg":"find cmd absolute path /usr/bin/stress","time":"2021-08-28T19:28:07Z"}
# stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd

# 宿主机执行
top
# top - 19:29:07 up  3:13,  2 users,  load average: 0.78, 0.32, 0.23
# Tasks: 263 total,   2 running, 261 sleeping,   0 stopped,   0 zombie
# %Cpu(s):  1.4 us, 10.0 sy,  0.0 ni, 85.9 id,  2.4 wa,  0.0 hi,  0.3 si,  0.0 st
# MiB Mem :  15985.9 total,  12479.2 free,   2334.3 used,   1172.4 buff/cache
# MiB Swap:  12288.0 total,  12140.3 free,    147.7 used.  13346.1 avail Mem
#
#    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
#  13981 root      20   0  208660 101480    336 R  74.8   0.6   0:45.72 stress

# 可以看到，仅仅占用了 15985.9 * 0.6% = 95.9154 ≈ 100M 内存

# 注：试验结束记得使用htop清理多余的stress进程！！！！！！！
