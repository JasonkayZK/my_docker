############################## Test 1：容器状态测试 ##############################
# 创建两个detach的容器：一个有名，一个无名
./my_docker run --name test  -d top

./my_docker run -d top

# 查看容器信息存储路径
pwd
# /var/run/my-docker

tree
# .
# ├── test
# │   └── config.json
# └── xuek9bpfae8k2bsa
#     └── config.json
#
# 2 directories, 2 files

# 可以看到对应的容器名称目录以及对应的配置文件

# 查看文件内容
cat test/config.json
# {"pid":"118128","id":"j5f5rjsycnun2p9b","name":"test","command":"top","createTime":"2021-09-18 16:31:57","status":"running","cgroups_infos":{"cpu":"512","cpu_set":"1","memory":"256m"},"volume_infos":[""]}

# 使用 `ps` 命令查看信息
./my_docker ps
# ID                 NAME               PID         STATUS      COMMAND     CREATED
# j5f5rjsycnun2p9b   test               118128      running     top         2021-09-18 16:31:57
# xuek9bpfae8k2bsa   xuek9bpfae8k2bsa   118269      running     top         2021-09-18 16:35:46


############################## Test End：清理无用数据和进程 #############################
cat test/config.json
# {"pid":"118128", ...
kill -9 118128

cat xuek9bpfae8k2bsa/config.json
# {"pid":"118269", ...
kill -9 118269

# 清除信息文件
rm -rf test/ xuek9bpfae8k2bsa/
