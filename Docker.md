# Docker

> Author：JH



Docker 这个小工具老是会忘记，所以做一点记录





### Docker中的基本概念

* 主要有三个基本概念
  * 镜像 (Image) 
  * 容器 (Container) 
  * 仓库(Registry) 类似与git repo 



在 Docker 中，镜像 (Image) 和容器 (Container) 是两个最核心的概念。

**镜像** 是只读的模板，包含运行应用程序所需的所有内容，包括代码、运行时环境、系统工具、系统库和配置文件等。镜像可以被用来创建多个容器。

**容器** 是镜像的运行时实例。它是一个独立的、可运行的环境，包含应用程序的所有运行时状态，例如进程、内存、存储、网络等。

**镜像与容器的关系** 可以类比为面向对象程序设计中的类和实例。镜像是静态的定义，容器是镜像运行时的实体。

**创建容器** 的过程是从镜像中克隆一个新的容器。克隆过程会将镜像中的所有内容复制到容器中，并为容器分配必要的资源。

**容器** 可以被启动、停止、删除、暂停等。容器的实质是进程，但与直接在宿主执行的进程不同，容器进程运行于属于自己的独立的命名空间。

**以下是 Docker 中镜像和容器的一些关键区别：**

| 特性     | 镜像                           | 容器                     |
| :------- | :----------------------------- | :----------------------- |
| 状态     | 只读                           | 可读写                   |
| 内容     | 包含应用程序所需的所有内容     | 包含应用程序的运行时状态 |
| 创建方式 | 从 Dockerfile 构建或从仓库下载 | 从镜像克隆               |
| 生命周期 | 持续存在直到被删除             | 可以被启动、停止、删除等 |
| 用途     | 用于创建容器                   | 用于运行应用程序         |

**总结**

Docker 镜像和容器是两个密切相关的概念。镜像是容器的模板，容器是镜像的运行时实例。理解镜像和容器之间的关系对于使用 Docker 非常重要。





### Supported backing filesystems

With regard to Docker, the backing filesystem is the filesystem where `/var/lib/docker/` is located. Some storage drivers only work with specific backing filesystems.

| Storage driver | Supported backing filesystems |
| :------------- | :---------------------------- |
| overlay2       | `xfs` with ftype=1, `ext4`    |
| fuse-overlayfs | any filesystem                |
| `btrfs`        | `btrfs`                       |
| `zfs`          | `zfs`                         |
| `vfs`          | any filesystem                |



### How To Install

大概安装的方式有三种:

* Apt-get 
* Debian 
* Script

这里选择使用docker 网站提供的脚步一步到位直接安装，最方便。如下一条命令搞定



~~~shell
sudo -i
curl -sS https://get.docker.com/ | sh

#启动
systemctl start docker
systemctl enable docker
systemctl status docker


sudo apt-get install -y uidmap

dockerd-rootless-setuptool.sh install

sudo usermod -aG docker $USER

~~~





### Docker CMD



去记这些命令挺没有意思的，直接看docker出来的cmd来的简单，不用网上看文档，但是这个cmd需要归类记忆，就是分为image与container的命令独立开来



记忆，要么他这些cmd设计的不怎么好，比较乱。本身不大合理与人类记忆。



##### All cmd

~~~shell

root:~/temp$ docker help

Usage:  docker [OPTIONS] COMMAND

A self-sufficient runtime for containers

Common Commands:
  run         Create and run a new container from an image
  exec        Execute a command in a running container
  ps          List containers
  build       Build an image from a Dockerfile
  pull        Download an image from a registry
  push        Upload an image to a registry
  images      List images
  login       Log in to a registry
  logout      Log out from a registry
  search      Search Docker Hub for images
  version     Show the Docker version information
  info        Display system-wide information

Management Commands:
  builder     Manage builds
  buildx*     Docker Buildx (Docker Inc., v0.13.0)
  checkpoint  Manage checkpoints
  compose*    Docker Compose (Docker Inc., v2.24.7)
  container   Manage containers
  context     Manage contexts
  image       Manage images
  manifest    Manage Docker image manifests and manifest lists
  network     Manage networks
  plugin      Manage plugins
  system      Manage Docker
  trust       Manage trust on Docker images
  volume      Manage volumes

Swarm Commands:
  config      Manage Swarm configs
  node        Manage Swarm nodes
  secret      Manage Swarm secrets
  service     Manage Swarm services
  stack       Manage Swarm stacks
  swarm       Manage Swarm

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  import      Import the contents from a tarball to create a filesystem image
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  wait        Block until one or more containers stop, then print their exit codes

Global Options:
      --config string      Location of client config files (default "/home/jello/.docker")
  -c, --context string     Name of the context to use to connect to the daemon (overrides DOCKER_HOST env var and default context set with "docker
                           context use")
  -D, --debug              Enable debug mode
  -H, --host list          Daemon socket to connect to
  -l, --log-level string   Set the logging level ("debug", "info", "warn", "error", "fatal") (default "info")
      --tls                Use TLS; implied by --tlsverify
      --tlscacert string   Trust certs signed only by this CA (default "/home/jello/.docker/ca.pem")
      --tlscert string     Path to TLS certificate file (default "/home/jello/.docker/cert.pem")
      --tlskey string      Path to TLS key file (default "/home/jello/.docker/key.pem")
      --tlsverify          Use TLS and verify the remote
  -v, --version            Print version information and quit

Run 'docker COMMAND --help' for more information on a command.

For more help on how to use Docker, head to https://docs.docker.com/go/guides/
root:~/temp$ 

~~~



##### Image cmd



~~~SHELL
docker image --help

Usage:  docker image COMMAND

Manage images

Commands:
  build       Build an image from a Dockerfile
  history     Show the history of an image
  import      Import the contents from a tarball to create a filesystem image
  inspect     Display detailed information on one or more images
  load        Load an image from a tar archive or STDIN
  ls          List images
  prune       Remove unused images
  pull        Download an image from a registry
  push        Upload an image to a registry
  rm          Remove one or more images
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE

Run 'docker image COMMAND --help' for more information on a command.
root:~/temp$ 

~~~



https://airdrops.io/

https://alphador.ai/crypto-events/fuel-testnet-and-airdrop-guide

#####  Container cmd

~~~shell
Usage:  docker container COMMAND

Manage containers

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  exec        Execute a command in a running container
  export      Export a container's filesystem as a tar archive
  inspect     Display detailed information on one or more containers
  kill        Kill one or more running containers
  logs        Fetch the logs of a container
  ls          List containers
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  prune       Remove all stopped containers
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  run         Create and run a new container from an image
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  wait        Block until one or more containers stop, then print their exit codes

Run 'docker container COMMAND --help' for more information on a command.

~~~



##### Usefull command



* Pull 某个版本，没有说明直接pull的话默认是最新版本

  

  ~~~shell
  # ubuntu is image name
  sudo docker image pull ubuntu:22.04
  
  
  $ docker image pull ubuntu:22.04
  22.04: Pulling from library/ubuntu
  bccd10f490ab: Pull complete 
  Digest: sha256:77906da86b60585ce12215807090eb327e7386c8fafb5402369e421f44eff17e
  Status: Downloaded newer image for ubuntu:22.04
  docker.io/library/ubuntu:22.04
  $ docker image ls
  
  REPOSITORY   TAG             IMAGE ID       CREATED       SIZE
  ubuntu       update_server   5aac14c3231e   4 weeks ago   688MB
  ubuntu       Init_server     6f1273a5b7b3   4 weeks ago   669MB
  ubuntu       22.04           ca2b0f26964c   6 weeks ago   77.9MB
  ubuntu       20.04           3cff1c6ff37e   8 weeks ago   72.8MB
  $ docker run -it ca2b0f26964c /bin/bash
  ~~~



* pull latest version from https://hub.docker.com/_/ubuntu

  ~~~
  
  sudo docker image pull ubuntu
  ~~~
  
* Depoly the complete  ubuntu

  ~~~shell 
  # 基本的工具安装好之后，最主要运行这个命令就可以了
  apt-get install -y iputils-ping
  apt-get install ubuntu-server
  
  
  ~~~

  


* List all container and image

  ~~~shell
  #需要增加-a选项，有时候删除image的时候会先去找container，没有找到，就出错
  
    sudo docker container ls -a
  sudo docker ps -a #等通于上面，并且可以列出所有的image与container
  
  
  sudo docker image ls -a
  
  ~~~

  

* Run docker

  

  ~~~shell
  # 3cff1c6ff37e is image id
  sudo docker run -it 3cff1c6ff37e /bin/bash
  
  # above run cmd will cause the below error 
  # System has not been booted with systemd as init system (PID 1). Can't operate. Failed to connect to bus: Host is down
  # Fix it to run below cmd
  
  # 5aac14c3231e is image id, It will luanch new container
  # 没有d，可以看到kernel log
  docker run -itd --privileged=true 5aac14c3231e /sbin/init
  
  
  root:~/temp$ docker ps
  CONTAINER ID   IMAGE          COMMAND        CREATED          STATUS          PORTS     NAMES
  f9978b9556bc   5aac14c3231e   "/sbin/init"   42 seconds ago   Up 41 seconds             silly_chebyshev
  root:~/temp$ docker ps
  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
  root:~/temp$ 
  # silly_chebyshev is container id or use names
  docker exec -it silly_chebyshev /bin/bash
  
  docker exec -it 22.04_ionet_reboot /bin/bash
  
  root:~/mw/2024/infinity/atomicals-js-infinity$ docker   ps
  CONTAINER ID   IMAGE          COMMAND        CREATED          STATUS         PORTS     NAMES
  cf46800d6b5c   5aac14c3231e   "/sbin/init"   27 minutes ago   Up 2 minutes             modest_bohr
  f9978b9556bc   5aac14c3231e   "/sbin/init"   48 minutes ago   Up 2 minutes             silly_chebyshev
  b94d5f510d3a   5aac14c3231e   "/sbin/init"   49 minutes ago   Up 2 minutes             upbeat_taussig
  d886e5a2f349   5aac14c3231e   "/sbin/init"   59 minutes ago   Up 7 seconds             gallant_hertz
  root:~/mw/2024/infinity/atomicals-js-infinity$ 
  
  
  # start containers, cf46800d6b5c is containers id
  docker start cf46800d6b5c f9978b9556bc b94d5f510d3a
  
  # start container gallant_hertz,containers is name
  docker start gallant_hertz
  
  
  
  
  ~~~

  

* Docker commit

~~~shell

root:~/temp$ docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
626a36cc1a22   6f1273a5b7b3   "/bin/bash"   6 minutes ago   Up 6 minutes             sleepy_morse
root:~/temp$ docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
ubuntu       Init_server   6f1273a5b7b3   7 minutes ago   669MB
ubuntu       20.04         3cff1c6ff37e   4 weeks ago     72.8MB

# 626a36cc1a22 is container id，update_server是我们取的tag名字
root:~/temp$ docker commit -m "Add some tool for ubuntu server" 626a36cc1a22 ubuntu:update_server



$ docker image ls
REPOSITORY   TAG             IMAGE ID       CREATED       SIZE
ubuntu       update_server   5aac14c3231e   4 weeks ago   688MB
ubuntu       Init_server     6f1273a5b7b3   4 weeks ago   669MB
ubuntu       22.04           ca2b0f26964c   6 weeks ago   77.9MB
ubuntu       20.04           3cff1c6ff37e   8 weeks ago   72.8MB



~~~



* Docker ps

~~~shell
同一个image 可以有多个CONTAINER在运行

root:~/temp$ docker ps -a
CONTAINER ID   IMAGE                  COMMAND        CREATED             STATUS                         PORTS     NAMES
cf46800d6b5c   5aac14c3231e           "/sbin/init"   3 minutes ago       Up 3 minutes                             modest_bohr
f9978b9556bc   5aac14c3231e           "/sbin/init"   24 minutes ago      Up 14 minutes                            silly_chebyshev
b94d5f510d3a   5aac14c3231e           "/sbin/init"   26 minutes ago      Up 4 minutes                             upbeat_taussig
3dc0392401d2   ubuntu:update_server   "/bin/bash"    30 minutes ago      Exited (0) 30 minutes ago                myubuntu
d886e5a2f349   5aac14c3231e           "/sbin/init"   35 minutes ago      Exited (137) 32 minutes ago              gallant_hertz
9dc6c729b4e7   5aac14c3231e           "/bin/bash"    45 minutes ago      Exited (1) 37 minutes ago                compassionate_chaum
82f78b4b5246   5aac14c3231e           "/bin/bash"    About an hour ago   Exited (0) 32 minutes ago                quizzical_chaum
a0d82cab3abd   5aac14c3231e           "/bin/bash"    About an hour ago   Exited (0) About an hour ago             competent_hermann
626a36cc1a22   6f1273a5b7b3           "/bin/bash"    About an hour ago   Exited (1) About an hour ago             sleepy_morse
5cbaeb818e47   3cff1c6ff37e           "/bin/bash"    2 hours ago         Exited (0) About an hour ago             heuristic_bartik
aeaad46a3d2d   3cff1c6ff37e           "/bin/bash"    5 hours ago         Exited (127) 4 hours ago                 boring_germain
d32bf2f03429   3cff1c6ff37e           "/bin/bash"    5 hours ago         Exited (127) 5 hours ago                 epic_kepler
root:~/temp$ 


~~~



##### Move docker images

~~~shell
systemctl stop docker
mv /var/lib/docker /data/docker
ln -sf /data/docker /var/lib/docker
~~~





* docker rename 原容器名称 新容器名称

  

##### Docker log



~~~

#6534b47ff4f3 is image id 
docker inspect  6534b47ff4f3 | grep -i Comment
~~~



### Build From Scratch



* Install vim for source.list

~~~shell
apt-get update

apt-get install vim -y 

~~~



* Source list

  vim  /etc/apt/sources.list

~~~shell
#linode 22.04 soruce.list
# 用outline代理非常快


deb http://mirrors.linode.com/ubuntu/ jammy main restricted
deb http://mirrors.linode.com/ubuntu/ jammy-updates main restricted
deb http://mirrors.linode.com/ubuntu/ jammy universe
# deb-src http://mirrors.linode.com/ubuntu/ jammy universe
deb http://mirrors.linode.com/ubuntu/ jammy-updates universe
# deb-src http://mirrors.linode.com/ubuntu/ jammy-updates universe
deb http://mirrors.linode.com/ubuntu/ jammy multiverse
# deb-src http://mirrors.linode.com/ubuntu/ jammy multiverse
deb http://mirrors.linode.com/ubuntu/ jammy-updates multiverse
# deb-src http://mirrors.linode.com/ubuntu/ jammy-updates multiverse
deb http://mirrors.linode.com/ubuntu/ jammy-backports main restricted universe multiverse   
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted
deb http://security.ubuntu.com/ubuntu/ jammy-security universe
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security universe
deb http://security.ubuntu.com/ubuntu/ jammy-security multiverse
# deb-src http://security.ubuntu.com/ubuntu/ jammy-security multiverse
~~~



* 基本的工具安装好之后，最主要运行这个命令就可以了

  

~~~shell
apt-get update
apt-get install ubuntu-server

~~~



* Install common command and update source.list  



~~~shell

apt-get install htop openssh-server tree  net-tools  iputils-ping  git libssl-dev -y
~~~



* sshd 配置root问题

  

~~~shell
vim /etc/ssh/sshd_config

PermitRootLogin yes

ssh-keygen -t rsa  -N "" -f ~/.ssh/id_rsa




COPY . /app

~~~



* 可能需要解决reboot问题（init）
* 







### portainer





### IONet 



https://medium.com/@yyjjkk08/%E5%85%A8%E4%B8%96%E7%95%8C%E6%9C%80%E7%89%9B%E9%80%BC%E7%9A%84io%E5%AE%89%E8%A3%85%E9%97%AE%E9%A2%98%E8%A7%A3%E5%86%B3%E6%96%B9%E6%B3%95-20fef3f52e07

https://mirror.xyz/zdaocrypto.eth/l2AwEnDCS5nqMqIGURaU7EdJDfKd-E97SmvV7SI8ASA



https://mirror.xyz/0x6EaD271a45ACc328Af22b369870509471a46f59D/AeKsFa6FehJK4-oEe1zAz0yzNhtVkyuT0cX1rCfJ_XA





##### pwd



my_password=3Q0GYHygXfhJZgK6q1WqaNlaYOX

##### Debug



~~~shell


e1cb2e3895a7   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   About a minute ago   Up About a minute             focused_cohen
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED              STATUS              PORTS     NAMES
e1cb2e3895a7   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   About a minute ago   Up About a minute             focused_cohen
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
e1cb2e3895a7   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             focused_cohen
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps -a
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
e1cb2e3895a7   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             focused_cohen
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker stop focused_cohen
focused_cohen
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps -a
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
c6c58ae84dab   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      21 seconds ago   Up 12 seconds             priceless_colden
9a928975ebac   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   33 seconds ago   Up 26 seconds             festive_yonath
4521b727f153   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   40 seconds ago   Up 34 seconds             unruffled_villani
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps   
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
c6c58ae84dab   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      23 seconds ago   Up 14 seconds             priceless_colden
9a928975ebac   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   35 seconds ago   Up 28 seconds             festive_yonath
4521b727f153   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   42 seconds ago   Up 36 seconds             unruffled_villani
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
c6c58ae84dab   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      24 seconds ago   Up 15 seconds             priceless_colden
9a928975ebac   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   36 seconds ago   Up 30 seconds             festive_yonath
4521b727f153   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   43 seconds ago   Up 38 seconds             unruffled_villani
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
c6c58ae84dab   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      25 seconds ago   Up 16 seconds             priceless_colden
9a928975ebac   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   37 seconds ago   Up 31 seconds             festive_yonath
4521b727f153   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   44 seconds ago   Up 38 seconds             unruffled_villani
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
c6c58ae84dab   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      21 minutes ago   Up 21 minutes             priceless_colden
9a928975ebac   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   21 minutes ago   Up 21 minutes             festive_yonath
root@9c729a193e1d:/home/ionet/io_launch_binaries# docker stop c6c58ae84dab 9a928975ebac
c6c58ae84dab
9a928975ebac
root@9c729a193e1d:/home/ionet/io_launch_binaries# 
root@9c729a193e1d:/home/ionet/io_launch_binaries# 
root@9c729a193e1d:/home/ionet/io_launch_binaries# 
root@9c729a193e1d:/home/ionet/io_launch_binaries# 



 docker stop $(docker ps -a -q); docker rm $(docker ps -q)

sudo nvidia-smi -pm 1
~~~





docker exec -it 22.04_ionet_reboot /bin/bash

docker start 22.04_ionet_reboot

https://developers.io.net/docs/ignition-rewards-program

https://hub.docker.com/u/ionetcontainers



https://hub.docker.com/u/ionetcontainers

./launch_binary_linux --device_id=e21afab2-1441-4053-b624-459908fc4fff --user_id=e46a0559-0906-485f-b674-f4f0e6c675f4 --operating_system="Linux" --usegpus=false --device_name=cpu1



If the devices that not support ,it will show "Unsupport " label on the Official website or can not connected to the Official website server ?



上的，梯子很便宜的比如几十块钱的，或者是那种直接下个软件就能用不用搞订阅链接的，建议直接换个好梯子，不知道买哪个可以私聊我推荐个及格的（我测速0.4G/s 0.3G/s medium speed，最高应该是1Gbps有推荐码是用来给我流量费回血的） ，可以买更贵的，直接找Top机场，如Nexitally、Kuromis

https://developers.io.net/docs/supported-devices





https://io.web3miner.io/ignition-rewards-program





##### cpuinfo



* 3995WX

~~~shell


SUT (System Under Test) info as seen by some common utilities.
 For more information on this section, see
 https://www.spec.org/cpu2017/Docs/config.html#sysinfo
 From /proc/cpuinfo
 model name : AMD Ryzen Threadripper PRO 3995WX 64-Cores
 1 "physical id"s (chips)
 128 "processors"
 cores, siblings (Caution: counting these is hw and system dependent. The following
 excerpts from /proc/cpuinfo might not be reliable. Use with caution.)
 cpu cores : 64
 siblings : 128
 physical 0: cores 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24
 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52
 53 54 55 56 57 58 59 60 61 62 63
 From lscpu:
 Architecture: x86_64
 CPU op-mode(s): 32-bit, 64-bit
 Byte Order: Little Endian
 Address sizes: 43 bits physical, 48 bits virtual
 CPU(s): 128
 On-line CPU(s) list: 0-127
 Thread(s) per core: 2
 Core(s) per socket: 64
 Socket(s): 1
 NUMA node(s): 1
 Vendor ID: AuthenticAMD
 CPU family: 23
 Model: 49
 
 
 
 Model name: AMD Ryzen Threadripper PRO 3995WX 64-Cores
 
 
 
 
processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 23
model		: 49
model name	: AMD Ryzen Threadripper PRO 3995WX 64-Cores
stepping	: 0
microcode	: 0x830104d
cpu MHz		: 2200.000
cache size	: 512 KB
physical id	: 0
siblings	: 128
core id		: 0
cpu cores	: 64
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 16
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid aperfmperf pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 movbe popcnt aes xsave avx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt tce topoext perfctr_core perfctr_nb bpext perfctr_llc mwaitx cpb cat_l3 cdp_l3 hw_pstate sme ssbd mba sev ibpb stibp vmmcall sev_es fsgsbase bmi1 avx2 smep bmi2 cqm rdt_a rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local clzero irperf xsaveerptr rdpru wbnoinvd arat npt lbrv svm_lock nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif umip rdpid overflow_recov succor smca
bugs		: sysret_ss_attrs spectre_v1 spectre_v2 spec_store_bypass
bogomips	: 5389.99
TLB size	: 3072 4K pages
clflush size	: 64
cache_alignment	: 64
address sizes	: 43 bits physical, 48 bits virtual
power management: ts ttp tm hwpstate cpb eff_freq_ro [13] [14]

 
 
 
~~~





* 7542

~~~shell


processor	: 0
vendor_id	: AuthenticAMD
cpu family	: 23
model		: 49
model name	: AMD EPYC 7542 32-Core Processor
stepping	: 0
microcode	: 0x830107a
cpu MHz		: 1500.000
cache size	: 512 KB
physical id	: 0
siblings	: 64
core id		: 0
cpu cores	: 32
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 16
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rd
tscp lm constant_tsc rep_good nopl nonstop_tsc cpuid extd_apicid aperfmperf rapl pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 movbe popcnt aes xsave a
vx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt tce topoext perfctr_core perfctr_nb bpext p
erfctr_llc mwaitx cpb cat_l3 cdp_l3 hw_pstate ssbd mba ibrs ibpb stibp vmmcall fsgsbase bmi1 avx2 smep bmi2 cqm rdt_a rdseed adx smap clflushopt clwb sha_ni
 xsaveopt xsavec xgetbv1 cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local clzero irperf xsaveerptr rdpru wbnoinvd amd_ppin arat npt lbrv svm_lock nrip_save
 tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif v_spec_ctrl umip rdpid overflow_recov succor smca sev sev_
es
bugs		: sysret_ss_attrs spectre_v1 spectre_v2 spec_store_bypass retbleed smt_rsb srso
bogomips	: 5799.87
TLB size	: 3072 4K pages
clflush size	: 64
cache_alignment	: 64
address sizes	: 43 bits physical, 48 bits virtual
power management: ts ttp tm hwpstate cpb eff_freq_ro [13] [14]

processor	: 1
vendor_id	: AuthenticAMD
cpu family	: 23
model		: 49
model name	: AMD EPYC 7542 32-Core Processor



~~~





Model name: AMD Ryzen Threadripper PRO 3995WX 64-Cores



##### cmd



* docker run -itd --privileged=true 5aac14c3231e /sbin/init

~~~shell
sudo systemctl stop docker;sudo systemctl stop docker.socket;sudo systemctl stop containerd


 docker stop $(docker ps -a -q)
 
 docker rm $(docker ps -q)
 
 
 # 5aac14c3231e is image id, It will luanch new container
# 没有d，可以看到kernel log
docker run -itd --privileged=true 5aac14c3231e /sbin/init


 
docker exec -it silly_chebyshev /bin/bash

docker exec -it 22.04_ionet_reboot /bin/bash
docker exec -it ionet225 /bin/bash
docker exec -it taoism /bin/bash 


root:~/bark$ docker images
REPOSITORY   TAG                IMAGE ID       CREATED        SIZE
ionet        work               4d1c61f1ba88   33 hours ago   50.2GB
ubuntu       22.04_init         88636916b36a   2 days ago     9.89GB
<none>       <none>             53852acce580   2 days ago     9.89GB
ubuntu       jello_init_22.04   46f9416122d4   2 days ago     814MB
ubuntu       update_server      5aac14c3231e   4 weeks ago    688MB
ubuntu       Init_server        6f1273a5b7b3   4 weeks ago    669MB
ubuntu       22.04              ca2b0f26964c   7 weeks ago    77.9MB
ubuntu       20.04              3cff1c6ff37e   2 months ago   72.8MB


#ubuntu是repo ，22.04_init是tag，类似于运行image id 88636916b36a
root:~/bark$ docker run -itd --privileged=true ubuntu:22.04_init /sbin/init

5152c0d72c3ba8abe8f94e17251ce40f67e4215a28e99eca23d1587e976d563d

root:~/bark$ docker ps
CONTAINER ID   IMAGE               COMMAND        CREATED         STATUS         PORTS     NAMES
5152c0d72c3b   ubuntu:22.04_init   "/sbin/init"   3 seconds ago   Up 2 seconds             hardcore_vaughan
9df39b5625bd   88636916b36a        "/sbin/init"   17 hours ago    Up 15 hours              ionet225
root:~/bark$ 



root:~/bark$ docker rename hardcore_vaughan taoism
root:~/bark$ docker ps
CONTAINER ID   IMAGE               COMMAND        CREATED         STATUS         PORTS     NAMES
5152c0d72c3b   ubuntu:22.04_init   "/sbin/init"   4 minutes ago   Up 4 minutes             taoism
9df39b5625bd   88636916b36a        "/sbin/init"   17 hours ago    Up 15 hours              ionet225
root:~/bark$ 


docker exec -it taoism /bin/bash



./launch_binary_linux --device_id=d21fd3c4-4dc0-4c38-ba72-f3b7067e3279 --user_id=8a1f166d-cbe8-43b4-918d-0843077c6f8a --operating_system="Linux" --usegpus=false --device_name=ionet229


~~~







##### Brief Cmd



~~~shell
docker images;docker ps -a;docker ps



docker start ionet225;docker exec -it ionet225 /bin/bash



docker commit -m "Test version and it is available" 5152c0d72c3b ionet:available



docker pull portainer/agent:2.20.1
docker service update --image portainer/agent:2.20.1 --force portainer_agent 
~~~



##### import image



~~~shell
You will need to save the Docker image as a tar file:

docker save -o <path for generated tar file> <image name>
Then copy your image to a new system with regular file transfer tools such as cp, scp, or rsync (preferred for big files). After that you will have to load the image into Docker:

docker load -i <path to image tar file>
~~~



##### log





~~~shell

root@9df39b5625bd:/home/ionet/io_launch_binaries# ./launch_binary_linux 
Stopping all running Docker containers...
22f44789613b
removing stale images: ionetcontainers/io-worker-monitor
Unable to find image 'ionetcontainers/io-launch:v0.1' locally
v0.1: Pulling from ionetcontainers/io-launch
d51af753c3d3: Already exists 
fc878cd0a91c: Already exists 
6154df8ff988: Already exists 
fee5db0ff82f: Already exists 
683986a13a30: Already exists 
ce3c10e81ca8: Already exists 
59d77bd0fe62: Already exists 
1846a873195f: Already exists 
d2b0af2fc044: Already exists 
81fe96bd6fb3: Pull complete 
a3775a4ca866: Pull complete 
40f29d4ae625: Pull complete 
c0362b6d9f3a: Pull complete 
4f4fb700ef54: Pull complete 
d67b73967b27: Pull complete 
c0a298126193: Pull complete 
fb30e8986d9a: Pull complete 
6e8677d8600f: Pull complete 
229601cf8d46: Pull complete 
3ac163499178: Pull complete 
Digest: sha256:f45453239c90f76278e97c61e64025b398315eb603b5f099141c44e88b5d9dc1
Status: Downloaded newer image for ionetcontainers/io-launch:v0.1
06f9340625b97c29ebcda4b18cc61361952e9af282f5edc23be3cf180da475e6

~~~



##### Success log1





~~~shell



root@9df39b5625bd:/home/ionet/io_launch_binaries# cat ionet_device_cache.txt 
{"device_name": "ionet225", "device_id": "96f25580-8558-46e1-b7f0-a0c80aeb09ac", "user_id": "8a1f166d-cbe8-43b4-918d-0843077c6f8a", "operating_system": "Linux", "usegpus": "false"}

root@9df39b5625bd:/home/ionet/io_launch_binaries# ./launch_binary_linux 
1f79fd6fac3054dadd38ba55d4f15c7254f891da30ec034cd94deffe4ec14b43
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   7 seconds ago   Up 3 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS                  PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   5 seconds ago    Up Less than a second             eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   11 seconds ago   Up 6 seconds                      wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS         PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   6 seconds ago    Up 1 second              eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   12 seconds ago   Up 7 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS         PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   7 seconds ago    Up 2 seconds             eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   13 seconds ago   Up 8 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   8 seconds ago    Up 4 seconds              eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   14 seconds ago   Up 10 seconds             wonderful_kowalevski
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   9 seconds ago    Up 4 seconds              eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   15 seconds ago   Up 10 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   10 seconds ago   Up 5 seconds              eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   16 seconds ago   Up 11 seconds             wonderful_kowalevski
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   13 seconds ago   Up 9 seconds              eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   19 seconds ago   Up 15 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
22f44789613b   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   15 seconds ago   Up 10 seconds             eloquent_darwin
1f79fd6fac30   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   21 seconds ago   Up 16 seconds             wonderful_kowalevski


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
a8f883fdba04   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      15 minutes ago   Up 15 minutes             unruffled_engelbart
22f44789613b   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   18 minutes ago   Up 18 minutes             eloquent_darwin
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# ps aux|grep docker
root         286 37.6  0.0 7466228 76608 ?       Ssl  08:30  24:48 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
root       13729  0.0  0.0   3472  1032 pts/1    S+   09:36   0:00 grep --color=auto docker
root@9df39b5625bd:/home/ionet/io_launch_binaries# htop
root@9df39b5625bd:/home/ionet/io_launch_binaries# ifconfig -a
docker0: flags=4099<UP


~~~









##### Success log2





<span  style="color: #ff1bce; ">5分钟之后才启动</span>

~~~shell



root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED         STATUS         PORTS     NAMES
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   2 minutes ago   Up 2 minutes             funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
ed5ff6e46ed2   ionetcontainers/io-worker-vc     "sudo -E /srp/invoke…"   15 seconds ago   Up 10 seconds             focused_hellman
06f9340625b9   ionetcontainers/io-launch:v0.1   "sudo -E /srp/invoke…"   5 minutes ago    Up 5 minutes              funny_hellman


root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
59e0a042740a   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      11 seconds ago   Up 4 seconds              eager_hertz
ed5ff6e46ed2   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   22 seconds ago   Up 17 seconds             focused_hellman
06f9340625b9   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   5 minutes ago    Up 5 minutes              funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# docker ps 
CONTAINER ID   IMAGE                               COMMAND                  CREATED          STATUS          PORTS     NAMES
59e0a042740a   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      13 seconds ago   Up 6 seconds              eager_hertz
ed5ff6e46ed2   ionetcontainers/io-worker-vc        "sudo -E /srp/invoke…"   24 seconds ago   Up 19 seconds             focused_hellman
06f9340625b9   ionetcontainers/io-launch:v0.1      "sudo -E /srp/invoke…"   5 minutes ago    Up 5 minutes              funny_hellman
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 
root@9df39b5625bd:/home/ionet/io_launch_binaries# 

~~~



TEDufYZfJx1mhf1ARhZSshphzkm8Y4on9c



0xec816a8639d6243eb4c4dcdc6568c1084f35b218





client advice speak involve glass pigeon grace old timber veteran common fiber



### Docker file




~~~
RUN curl -L https://downloads.portainer.io/ee2-20/portainer-agent-stack.yml -o portainer-agent-stack.yml
RUN docker stack deploy -c portainer-agent-stack.yml portainer

RUN apt-get install -y python3
RUN apt install build-essential cmake gpg unzip pkg-config software-properties-common ubuntu-drivers-common -y
RUN apt install libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev -y
RUN apt install libjpeg-dev libpng-dev libtiff-dev -y  
RUN apt install libavcodec-dev libavformat-dev libswscale-dev libv4l-dev -y  
RUN apt install libxvidcore-dev libx264-dev -y
RUN apt install libopenblas-dev libatlas-base-dev liblapack-dev gfortran -y  
RUN apt install libhdf5-serial-dev -y  
RUN apt install python3-dev python3-tk curl gnupg-agent dirmngr alsa-utils -y
RUN apt install libgtk-3-dev -y  

~~~





### Debug







~~~shell
INFO[2024-06-24T10:12:45.432703757+02:00] Starting up                                  
INFO[2024-06-24T10:12:45.479709805+02:00] [graphdriver] trying configured driver: overlay2 
ERRO[2024-06-24T10:12:45.485371336+02:00] failed to mount overlay: invalid argument     storage-driver=overlay2
failed to start daemon: error initializing graphdriver: driver not supported: overlay2



~~~



### portainer

~~~shell

curl -L https://downloads.portainer.io/ee2-20/portainer-agent-stack.yml -o portainer-agent-stack.yml
sudo docker stack deploy -c portainer-agent-stack.yml portainer


docker stack rm portainer;docker service rm portainer_edge_agent;docker volume rm portainer_portainer_data
~~~



3-qCT2UCLB+sZYFoXJPWy38Ft64OcJsuPbTA86J5T+q8Ob+5ylg4c+P+ocZLuI5ukWpXo2jcAJIw==





### Systemctl



/etc/systemd/system/multi-user.target.wants/docker.service

Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /lib/systemd/system/docker.service



##### /etc/systemd/system/docker-btrfs1.service



~~~shell
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target docker.socket firewalld.service containerd.service time-set.target
Wants=network-online.target containerd.service
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutStartSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process
                                                                                                                                              1,1 
OOMScoreAdjust=-500

[Install]
WantedBy=multi-user.target
                                 

~~~





##### two instant



##### /etc/systemd/system/docker-btrfs1.service



### Ref

* https://docs.docker.com/engine/install/ubuntu/
* https://platform.arkhamintelligence.com/
