# 环境：
docker -v                                        # Docker version 19.03.8, build afacb8b7f0

# 显示当前的镜像层文件
# 过时：ls /var/lib/docker/aufs/diff, 目前Docker已经使用overlay2
ls /var/lib/docker/image/overlay2/layerdb/sha256 # 空的目录

# 拉取镜像
docker pull ubuntu:15.04

# build镜像
docker build -t changed-ubuntu .
docker history changed-ubuntu

# 查看系统AUFS的配置
cat /sys/fs/aufs/config
#CONFIG_AUFS_FS=m
#CONFIG_AUFS_BRANCH_MAX_127=y
#CONFIG_AUFS_SBILIST=y
#CONFIG_AUFS_EXPORT=y
#CONFIG_AUFS_INO_T_64=y
#CONFIG_AUFS_XATTR=y
#CONFIG_AUFS_DIRREN=y
#CONFIG_AUFS_BR_HFSPLUS=y
#CONFIG_AUFS_BDEV_LOOP=y
