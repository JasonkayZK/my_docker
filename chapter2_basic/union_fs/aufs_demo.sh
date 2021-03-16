############################ 创建AUFS目录 ############################
mkdir aufs
cd aufs/
mkdir mnt
mkdir container-layer
echo "I am a container layer" >./container-layer/container-layer.txt
mkdir image-layer1 && mkdir image-layer2 && mkdir image-layer3 && mkdir image-layer4
echo "I am image layer1" >image-layer1/image-layer1.txt
echo "I am image layer2" >image-layer2/image-layer2.txt
echo "I am image layer3" >image-layer1/image-layer3.txt
echo "I am image layer4" >image-layer1/image-layer4.txt

tree
#.
#├── container-layer
#│   ├── container-layer.txt
#│   └── image-layer4.txt
#├── image-layer1
#│   └── image-layer1.txt
#├── image-layer2
#│   └── image-layer2.txt
#├── image-layer3
#│   └── image-layer3.txt
#├── image-layer4
#│   └── image-layer4.txt
#└── mnt

############################ 挂载目录到mnt ############################
pwd # /home/jasonkay/aufs
sudo mount -t aufs -o dirs=./container-layer:./image-layer4:./image-layer3:./image-layer2:./image-layer1 node ./mnt
tree mnt/
#mnt/
#├── container-layer.txt
#├── image-layer1.txt
#├── image-layer2.txt
#├── image-layer3.txt
#└── image-layer4.txt
#
#0 directories, 5 files

cat /sys/fs/aufs/si_1a784f858fb7a711/*
#/home/jasonkay/aufs/container-layer=rw
#/home/jasonkay/aufs/image-layer4=ro
#/home/jasonkay/aufs/image-layer3=ro
#/home/jasonkay/aufs/image-layer2=ro
#/home/jasonkay/aufs/image-layer1=ro
#64
#65
#66
#67
#68
#/home/jasonkay/aufs/container-layer/.aufs.xino

############################ 修改layer-4 ############################
echo -e "\nwrite to mnt's image-layer4.txt" >>./mnt/image-layer4.txt
cat mnt/image-layer4.txt
#I am image layer4
#
#write to mnt's image-layer4.tx

cat image-layer4/image-layer4.txt
#I am image layer4

ll container-layer/
#total 24
#drwxr-xr-x 4 jasonkay jasonkay 4096 3月  16 14:32 ./
#drwxr-xr-x 8 jasonkay jasonkay 4096 3月  16 14:23 ../
#-rw-r--r-- 1 jasonkay jasonkay   21 3月  16 14:23 container-layer.txt
#-rw-r--r-- 1 jasonkay jasonkay   51 3月  16 14:32 image-layer4.txt
#-r--r--r-- 1 root     root        0 3月  16 14:29 .wh..wh.aufs
#drwx------ 2 root     root     4096 3月  16 14:29 .wh..wh.orph/
#drwx------ 2 root     root     4096 3月  16 14:29 .wh..wh.plnk/

cat container-layer/image-layer4.txt
#I am image layer4
#
#write to mnt's image-layer4.txt

# 可见，修改image-layer4.txt后，挂载的nmt目录下的文件修改了，但是源文件没有修改，而是在contanner-layer中CoW了一个image-layer4.txt

############################ 复原：取消挂载 ############################
pwd # /home/jasonkay/aufs
sudo umount ./mnt
ls /sys/fs/aufs/ # config
