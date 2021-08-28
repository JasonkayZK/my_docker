# sleep一秒钟是让配置先生效，然后再在子进程中进行初始化，然后执行用户自定义命令！

############################## Test 2：宿主机内存测试 ##############################

./my_docker run -ti -m 100m -- stress --vm-bytes 200m --vm-keep -m 1
# {"level":"info","msg":"init come on","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"cmdArray [stress --vm-bytes 200m --vm-keep -m 1]","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"sleep 1 second, wait for config!","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 10932","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 10932","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 10932","time":"2021-08-28T18:40:04Z"}
# {"level":"info","msg":"find cmd absolute path /usr/bin/stress","time":"2021-08-28T18:40:05Z"}
# stress: info: [1] dispatching hogs: 0 cpu, 0 io, 1 vm, 0 hdd

htop
# top - 18:41:03 up  2:25,  2 users,  load average: 0.83, 0.37, 0.30
# Tasks: 258 total,   2 running, 256 sleeping,   0 stopped,   0 zombie
# %Cpu(s):  1.4 us, 10.2 sy,  0.0 ni, 86.3 id,  2.0 wa,  0.0 hi,  0.2 si,  0.0 st
# MiB Mem :  15985.9 total,  12632.4 free,   2232.8 used,   1120.7 buff/cache
# MiB Swap:  12288.0 total,  12186.5 free,    101.5 used.  13449.8 avail Mem
#
#    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
#  10937 root      20   0  208660 101528    272 R  78.1   0.6   0:46.39 stress

# 可以看到，仅仅占用了 15985.9 * 0.6% = 95.9154 ≈ 100M 内存

# 注：试验结束记得使用htop清理多余的stress进程！！！！！！！
