############################## Test 1：容器日志测试 ##############################
# 启动容器
./my_docker run -d top

# 查看log文件
pwd
# /var/run/my-docker

tree
# .
# └── 37d3t65l301o6oa2
#     ├── config.json
#     └── container.log
#
# 1 directory, 2 files

cat 37d3t65l301o6oa2/container.log
# Mem: 4555924K used, 11813636K free, 1616K shrd, 295228K buff, 1606264K cached
# CPU:  0.3% usr  0.3% sys  0.0% nic 99.3% idle  0.0% io  0.0% irq  0.0% sirq
# Load average: 0.23 0.13 0.12 3/465 5
#   PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
# root@jasonkay:/var/run/my-docker# .0   1  0.0 top

# 使用命令查看log
./my_docker logs 37d3t65l301o6oa2
# Mem: 4557360K used, 11812200K free, 1620K shrd, 295228K buff, 1606400K cached
# CPU:  0.2% usr  0.2% sys  0.0% nic 99.4% idle  0.0% io  0.0% irq  0.0% sirq
# Load average: 0.20 0.14 0.12 2/467 5
#   PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND


############################## Test End：清理无用数据和进程 #############################
cat 37d3t65l301o6oa2/config.json
# {"pid":"120243", ...
kill -9 120243

# 清除信息文件
rm -rf 37d3t65l301o6oa2/
