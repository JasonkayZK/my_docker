## My Docker

### 开发环境

- Ubuntu 20.04
- Golang 1.17

```bash
$ uname -a
Linux jasonkay 5.4.0-81-generic #91-Ubuntu SMP Thu Jul 15 19:09:17 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux

$ docker version
Client: Docker Engine - Community
 Version:           20.10.8
 API version:       1.41
 Go version:        go1.16.6
 Git commit:        3967b7d
 Built:             Fri Jul 30 19:54:27 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true
```


> 在Windows下使用Goland进行开发时，需要将settings→Go→Build Tags & Vendoring下的OS修改为linux 


### 资源获取

书籍《自己动手写Docker》的学习笔记；

书籍获取地址：

- Github Pages：https://jasonkayzk.github.io/sharing/
- 国内Gitee镜像：https://jasonkay.gitee.io/sharing/


### 实验说明

- 使用`mount`命令挂载后的目录，请在实验后使用`umount`命令取消挂载

