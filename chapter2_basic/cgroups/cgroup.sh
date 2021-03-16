# 环境: Ubuntu 20.04
uname -a # Linux jasonkayPC 5.4.0-58-generic #64-Ubuntu SMP Wed Dec 9 08:16:25 UTC 2020 x86_64 x86_64 x86_64 GNU/Linux

################### 查看内核支持的subsystem ###################
sudo apt install cgroup-tools

lssubsys -a

################### 创建cgroup ###################
cd ~ && pwd # /home/jasonkay
# 创建一个hierarchy挂载点
mkdir cgroup-test
# 挂载一个hierarchy
sudo mount -t cgroup -o none,name=cgroup-test cgroup-test ./cgroup-test
# 查看文件:
ls ./cgroup-test        # cgroup.clone_children  cgroup.sane_behavior  release_agent cgroup.procs notify_on_release tasks

################### 创建子cgroup ###################
cd ./cgroup-test && pwd # /home/jasonkay/cgroup-test
sudo mkdir cgroup-1     # 创建子cgroup "cgroup-1"
sudo mkdir cgroup-2     # 创建子cgroup "cgroup-2"
tree
#jasonkay@jasonkayPC:~/workspace/cgroup-test$ tree
#.
#├── cgroup-1
#│   ├── cgroup.clone_children
#│   ├── cgroup.procs
#│   ├── notify_on_release
#│   └── tasks
#├── cgroup-2
#│   ├── cgroup.clone_children
#│   ├── cgroup.procs
#│   ├── notify_on_release
#│   └── tasks
#├── cgroup.clone_children
#├── cgroup.procs
#├── cgroup.sane_behavior
#├── notify_on_release
#├── release_agent
#└── tasks
#
#2 directories, 14 files

################### 在cgroup中添加和移动进程 ###################
pwd # /home/jasonkay/workspace/cgroup-test/cgroup-1
echo $$ # 16141
sudo sh -c "echo $$ >> tasks" # 将所在终端检测移动至cgroup-1中
cat /procs/16141/cgroup
#13:name=cgroup-test:/cgroup-1
#12:net_cls,net_prio:/
#11:memory:/test-limit-memory
#10:rdma:/
#9:perf_event:/
#8:blkio:/user.slice
#7:freezer:/
#6:cpu,cpuacct:/user.slice
#5:hugetlb:/
#4:pids:/user.slice/user-1000.slice/session-26.scope
#3:cpuset:/
#2:devices:/user.slice
#1:name=systemd:/user.slice/user-1000.slice/session-26.scope
#0::/user.slice/user-1000.slice/session-26.scope
cat tasks # 16141 17917

################### 通过subsystem限制cgroup中进程的资源 ###################
mount | grep memory # cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cd /sys/fs/cgroup/memory && pwd # /sys/fs/cgroup/memory
# 安装stress
sudo apt install stress
# 不做限制的情况下进行测试
stress --vm-bytes 200m --vm-keep -m 1 &
# 输入top，并查看stress内存占用 /stress 为 200M

# 创建cgroup
sudo mkdir test-limit-memory && cd test-limit-memory && pwd # /sys/fs/cgroup/memory/test-limit-memory
# 设置cgroup的最大内存占用为100M
sudo sh -c "echo "100m" > memory.limit_in_bytes"
# 将当前进程移动至该cgroup中
sudo sh -c "echo $$ > tasks"
# 再次运行stress
stress --vm-bytes 200m --vm-keep -m 1 &
# 输入top，并查看stress内存占用 /stress 此时为100M了

