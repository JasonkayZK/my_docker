############################## Test 1：命令执行测试 ##############################
./my_docker run -ti -m 100m -- ls /

# 输出如下：
# {"level":"info","msg":"init come on","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"set cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/cpuset.cpus, cpu-set num: 1","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"set memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/memory.limit_in_bytes, size: 100m","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"set cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/cpu.shares, cpu-share: 512","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"apply cpu-set success, file: /sys/fs/cgroup/cpuset/mydocker-cgroup/tasks, pid: 13868","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"apply memory success, file: /sys/fs/cgroup/memory/mydocker-cgroup/tasks, pid: 13868","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"apply cpu-share success, file: /sys/fs/cgroup/cpu,cpuacct/mydocker-cgroup/tasks, pid: 13868","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"command all is ls /","time":"2021-08-28T19:26:32Z"}
# {"level":"info","msg":"find cmd absolute path /usr/bin/ls","time":"2021-08-28T19:26:32Z"}
# bin   cdrom  etc   lib    lib64   lost+found  mnt  proc  run   snap  swap.img  tmp  var
# boot  dev    home  lib32  libx32  media       opt  root  sbin  srv   sys       usr

# 可以看到，不再需要在Init中Sleep一秒钟等待资源限制配置完成！
