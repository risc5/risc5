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


sudo usermod -aG docker $USER

~~~





### Docker CMD



去记这些命令挺没有意思的，直接看docker出来的cmd来的简单，不用网上看文档，但是这个cmd需要归类记忆，就是分为image与container的命令独立开来



记忆，要么他这些cmd设计的不怎么好，比较乱。本身不大合理与人类记忆。



##### All cmd

~~~shell

jello@Santa:~/temp$ docker help

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
jello@Santa:~/temp$ 

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
jello@Santa:~/temp$ 

~~~





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



* Pull 某个版本，没有说明直接pull的话默认是最新版本

  

  ~~~shell
  # ubuntu is image name
  sudo docker image pull ubuntu:20.04
  
# pull latest version from https://hub.docker.com/_/ubuntu
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
  
  
  jello@Santa:~/temp$ docker ps
  CONTAINER ID   IMAGE          COMMAND        CREATED          STATUS          PORTS     NAMES
  f9978b9556bc   5aac14c3231e   "/sbin/init"   42 seconds ago   Up 41 seconds             silly_chebyshev
  jello@Santa:~/temp$ docker ps
  CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
  jello@Santa:~/temp$ 
  # silly_chebyshev is container id or use names
  docker exec -it silly_chebyshev /bin/bash
  
  
  
  jello@Santa:~/mw/2024/infinity/atomicals-js-infinity$ docker   ps
  CONTAINER ID   IMAGE          COMMAND        CREATED          STATUS         PORTS     NAMES
  cf46800d6b5c   5aac14c3231e   "/sbin/init"   27 minutes ago   Up 2 minutes             modest_bohr
  f9978b9556bc   5aac14c3231e   "/sbin/init"   48 minutes ago   Up 2 minutes             silly_chebyshev
  b94d5f510d3a   5aac14c3231e   "/sbin/init"   49 minutes ago   Up 2 minutes             upbeat_taussig
  d886e5a2f349   5aac14c3231e   "/sbin/init"   59 minutes ago   Up 7 seconds             gallant_hertz
  jello@Santa:~/mw/2024/infinity/atomicals-js-infinity$ 
  
  
  # start containers, cf46800d6b5c is containers id
  docker start cf46800d6b5c f9978b9556bc b94d5f510d3a
  
  # start container gallant_hertz,containers is name
  docker start gallant_hertz
  
  
  
  
  ~~~

  

* Docker commit

~~~shell

jello@Santa:~/temp$ docker ps 
CONTAINER ID   IMAGE          COMMAND       CREATED         STATUS         PORTS     NAMES
626a36cc1a22   6f1273a5b7b3   "/bin/bash"   6 minutes ago   Up 6 minutes             sleepy_morse
jello@Santa:~/temp$ docker images
REPOSITORY   TAG           IMAGE ID       CREATED         SIZE
ubuntu       Init_server   6f1273a5b7b3   7 minutes ago   669MB
ubuntu       20.04         3cff1c6ff37e   4 weeks ago     72.8MB

# 626a36cc1a22 is container id，update_server是我们取的tag名字
jello@Santa:~/temp$ docker commit -m "Add some tool for ubuntu server" 626a36cc1a22 ubuntu:update_server




~~~



* Docker ps

~~~shell
同一个image 可以有多个CONTAINER在运行

jello@Santa:~/temp$ docker ps -a
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
jello@Santa:~/temp$ 


~~~





### Ref

* https://docs.docker.com/engine/install/ubuntu/