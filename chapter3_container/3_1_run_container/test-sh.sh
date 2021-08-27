# 执行，并创建容器
./my_docker run -ti /bin/sh
# 输出：
# {"level":"info","msg":"init come on","time":"2021-08-27T16:08:29Z"}
# {"level":"info","msg":"command /bin/sh","time":"2021-08-27T16:08:29Z"}

# 容器内执行
ps -ef

# 输出：
# UID          PID    PPID  C STIME TTY          TIME CMD
# root           1       0  0 16:08 pts/4    00:00:00 /bin/sh
# root           6       1  0 16:08 pts/4    00:00:00 ps -ef