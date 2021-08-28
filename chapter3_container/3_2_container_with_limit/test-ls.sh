# sleep一秒钟是让配置先生效，然后再在子进程中进行初始化，然后执行用户自定义命令！

############################## Test 1：命令执行测试 ##############################
./my_docker run -ti -m 100m -- ls
# 输出结果：
# {"level":"info","msg":"init come on","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"cmdArray [ls]","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"sleep 1 second, wait for config!","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 10709","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 10709","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 10709","time":"2021-08-28T18:34:32Z"}
# {"level":"info","msg":"find cmd absolute path /usr/bin/ls","time":"2021-08-28T18:34:33Z"}
# cgroups  cmd  container  go.mod  go.sum  main.go  my_docker  test-ls.sh


