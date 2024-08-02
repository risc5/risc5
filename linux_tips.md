## Note Is More Power Than Memory 
> We need to clear our memory at intervals. Donot remember it 

- find ./ -perm /+x -type f 

1 2 4 more difficutly to remember

1 ----<>x 

2 ----<>w 

4 ----<>r 

- 查找并删除*.so文件

  ```shell
  find . -name "*.so" | xargs rm
  ```

- 查找并拷贝*.so文件

  ```shell
  find . -name "*.so" | xargs -i cp {} ./tmp/
  ```

- 拷贝当前目录下所有*.so文件到./tmp/下

  ```shell
  ls *.so | xargs -i cp {} ./tmp/
  ```

- Open the current dir

  ```shell
         alias opwd='nautilus `pwd`'
         
  
  ```

- To check hex in vim 

  ```shell
        #% is the whole file 
        :%!xxd
        
  
  ```
- To del the whole file content in vim 

  ```shell
        #% is the whole file 
        :%d
        
  
  ```
  
- To find size more than 1G

  ```shell
        find . -size +1G
  
  ```

- To find file and vim open it with 3 ways

  ```shell
        find -name somefile.txt -exec vim {} \;
        find -name somefile.txt;vim `-1`
        vim `find -name somefile.txt`
  
  ```

- allocate swap file

  ```shell
        sudo fallocate -l 8G swapfile
        sudo chmod 600 swapfile
        sudo mkswap swapfile
        sudo swapon swapfile

        sudo vim /etc/fstab
        /root/swapfile                                none            swap    sw              0       0

  
  ```

- To cp file with progress

  ```shell
        
        
        gcp file1 file2
  
  ```

- vim share clipboard with system 

  ```shell
        
        
        let mapleader = ";" 
        noremap <Leader>y "*y 
        noremap <Leader>p "*p 
        noremap <Leader>Y "+y 
        noremap <Leader>P "+p 
        :set backspace=indent,eol,start
  
  ```
  
- Iphone share hotspot with usb on ubuntu platform

  ```shell
        
        
        sudo apt install ipheth-utils libimobiledevice-dev libimobiledevice-utils
  
  ```
  
- Show Progress of the job,like tar,cp,mv etc

  ```shell
        
        
        sudo apt install progress
        
        cp file1 file2 | progress $!
  ```
  
  - resize the disk volume

  ```shell
        
        
  resize2fs -f /dev/mmcblk1p8
  
  ```

  ```shell
        
   # 2>&1来将标准错误信息重定向out文件
  ./get_disk_nohup.sh  >>nohup_nvme0_`date  +%Y%m%d.%H%M`.out 2>&1
  
  ```
  
- Install shadowsocks

  ```shell
        
        
  sudo apt-get install shadowsocks-libev
  ss-local -v -c ss.json
  
  ```
  
- Add user to root

  ```shell
        
        
  usermod -aG sudo username 

  usermod -aG docker username 
  ```
  
- How to install nginx
see nginx_default file on repo

  ```shell

  sudo apt install nginx -y

  mkdir -p /var/www/html

  sudo vim /etc/nginx/sites-available/default
        location /d {
                autoindex on; 
        } 

  sudo nginx -s reload
  ```

```shell
  
- Git archive

  ```shell
  git archive --format=zip --output master.zip master
  
```

- Install ss  

```shell
  brew install shadowsocks-libev
  brew services restart shadowsocks-libev
```

- sed replace text

  ```shell
  	sed -i 's/text/replace/' file
    
    # all file
    find ./ -type f -exec sed -i -e 's/0.875/0.2/g' {} \; 
    
    # for mac workaroud
    find . -type f -print0 | xargs -0 perl -pi -e 's/was/now/g'
  ```

- How long time process live

  ```shell
  ps -eo pid,lstart,etime | grep 2001
  ```

- vim cheate sheet 

  ```shell
  #delete the word under cursor
  diw
  https://vim.rtorr.com/
  ```




 - uudi 

  ```shell
   sudo blkid
  ```


- check memory chip info

  ```shell
   sudo dmidecode -t memory
   # Desktop Management Interface
  ```



- 相对路径

  ```shell
   这样写就可以解决了
  tar -czvf /home/futong/test/logs.tar.gz /home/futong/test/logs
  改成
  tar -czvf /home/futong/test/logs.tar.gz -C /home/futong/test logs
  ```

注意最后要打包的文件前面是空格
  ```
  
- encry
 
 ```shell
 
 tar -czf - IMG_0177.jpg | openssl enc -e -aes256 -out 2.tar.gz

openssl enc -d -aes256 -in 2.tar.gz | tar xz

  ```

- 烧写工具

* Win32 Disk Imager  
* Etcher

  
- Ubuntu 版本选择

 ```shell
 
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2

sudo update-alternatives --install /usr/bin/python python /usr/bin/python2 1

sudo update-alternatives --list python

sudo update-alternatives --config python

值越大优先级越大

 ```

- Cpio 

 ```shell
 
 # 解压cpio.gz文件
gzip -cd foo.cpio.gz | cpio -ivdu

find . -depth|cpio -ov >../a.cpio

cpio -ivdu < foo.cpio.gz

 ```

- mount ext4 image file

 ```shell
 
 # 
sudo mount -o loop rootfs.ext4 /mnt

 ```


- swappiness

 ```shell
# temp change
sudo sysctl vm.swappiness=20

sudo vim /etc/sysctl.conf
vm.swappiness = 20


 ```


 -  Error redirect


 ```shell
cat 1.txt 2.txt 2>/dev/null


 ```shell
 


 ```

* Some cmd and hardware info

~~~
NetworkManager cli

networking 可以简写为 n、ne、net、netw…… 所以以上命令可以简写为：
nmcli n

DMI是英文单词Desktop Management Interface的缩写，也就是桌面管理界面，它含有关于系统硬件的配置信息
sudo dmidecode -t 2

sudo dmidecode -t baseboard
上面2种是一样的

sudo dmidecode -t --help
Invalid type keyword: --help
Valid type keywords are:
  bios
  system
  baseboard
  chassis
  processor
  memory
  cache
  connector
  slot


lspci to check ether device

lspci | grep 'network|ethernet'

~~~







* open files limit

  ~~~shell
  ulimit -a
  ulimit -n 90485760
  
  
  
  ~~~

  

* lsof

~~~shell

lsof是系统管理/安全的尤伯工具。我大多数时候用它来从系统获得与网络连接相关的信息，但那只是这个强大而又鲜为人知的应用的第一步。将这个工具称之为lsof真实名副其实，因为它是指“列出打开文件（lists openfiles）”。而有一点要切记，在Unix中一切（包括网络套接口）都是文件。

https://linux.cn/article-4099-1.html


对于我，lsof替代了netstat和ps的全部工作。它可以带来那些工具所能带来的一切，而且要比那些工具多得多。那么，让我们来看看它的一些基本能力吧：

sudo lsof +D /media/jello


~~~





*  set  timezone 

  ~~~shell
  #ubuntu 
  dpkg-reconfigure tzdata

  timedatectl set-timezone Europe/Amsterdam
  timedatectl
  ~~~


timedatectl list-timezones
  ~~~

  



* open files limit



​~~~shell

prlimit
ulimit -a
#temp set
ulimit -n 99999
vim /etc/security/limits.conf 



* soft nproc 90485760
* hard nproc 90485760
* soft nofile 90485760
* hard nofile 90485760
root soft nproc 90485760
root hard nproc 90485760
root soft nofile 90485760
root hard nofile 90485760

#本地terminal 打開時候受這個影響

cat /proc/sys/fs/inotify/max_user_instances
vim /etc/systemd/user.conf

DefaultLimitNOFILE=90485760



vim  /etc/sysctl.conf 

fs.file-max=90485760
vm.max_map_count=90485760
fs.inotify.max_user_instances=99999
fs.inotify.max_user_watches=5524288



http://www.bictor.com/2022/07/17/ubuntu-16-04-modify-open-file-limits/
  ~~~



* terminal prompt name

  ~~~
  vim ~/.bashrc
  
  export PS1='[\u@\h \w]$ '
  其中，\u 表示当前用户名   \h 表示当前主机名（hostname） \w 表示当前路径
  
  export PS1='[\u@jello \w]$ '
  ~~~

  

* 列出相應的進程名字

  ~~~shell
  
  pgrep -a python3
  
  pgrep -fa python3
  
  pgrep和pkill命令某种程度上可以理解成 ps aux|grep [pattern] 的别名。
  
  pgrep 和 pkill 结合使用
  查找并结束指定名称的进程：
  ~~~

pkill -f "process_pattern"
-f 参数允许模糊匹配进程名或命令行参数。

 pkill  -x program_name 结束掉 进程名为 program_name 的进程，x参数启用精确匹配

總之使用好x與f參賽
  ~~~

  

* vim ctrl v模式

​~~~shell

1、删除一列操作：

     Ctrl + v ，切换到 VISUAL BLOCK 模式， 按下j（向下）或者k（向上）可以自由按序选中同一列的字符，然后x或者d键均可以删除。

2、删除连续多列操作：

    Ctrl+v，切换到切换到 VISUAL BLOCK 模式， 按下j或者k ，可以选择当前列所需要删除的连续行， 结合G键可以快速选中到文末，注意，如果鼠标所在字符不是第一列时，按下G，其实是选中了一片区域的，然后按x或者d键进行删除。

3、在多行的相同位置插入相同内容：

   Ctrl+v，切换到切换到 VISUAL BLOCK 模式，使用j或者k，选中想要在相同位置插入相同内容的行，按下shift + i，进入插入模式，输入想需要添加的内容，然后按两下ESC键，你就会发现，选中的行，内容都神奇地加上去了，很方便吧

  ~~~


* pip install version

~~~shell
pip install ccxt==1.2.2
pip  show ccxt


~~~

* install ubuntu security update

  ~~~shell
  
  apt-get install unattended-upgrades 
  
  #update all 
  apt-get upgrade
  ~~~

  

* 查询网站相关信息

  ~~~shell
  
  dig api.push.apple.com
  
  查询各种DNS记录的信息，包括主机地址，邮件交换和域名服务器
  dig命令是常用的域名查询工具，可以用于检查域名系统是否正常工作。可以查询DNS的NS、A、cname、mx等相关的信息记录。
  ~~~

 

　rsync -avP bigfolder/ /path/to/backup 
sudo rsync -axPS /var/lib/docker/ /path/to/new/docker-data
journalctl -xeu docker.service

注意要加反斜杆
rsync -avh empyt/ mw1/ --delete

Ubuntu中的systemctl是英文单词system control的缩写，意思是系统控制。

Systemd是System and Service Manager的缩写，是Linux系统中一种新的init系统，用于管理系统的启动和运行。Systemd取代了传统的init系统，例如System V init和Upstart。

Systemd使用unit文件来描述系统服务，而systemctl命令用于管理这些unit文件。systemctl命令可以用来启动、停止、重启、禁用、启用和检查服务状态。

因此，systemctl命令是systemd的一部分，用于管理systemd服务。

以下是systemctl命令的一些常见用法：

systemctl start <unit>：启动指定的unit
systemctl stop <unit>：停止指定的unit
systemctl restart <unit>：重启指定的unit
systemctl disable <unit>：禁用指定的unit
systemctl enable <unit>：启用指定的unit
systemctl status <unit>：检查指定的unit状态
例如，要启动名为httpd的服务，可以使用以下命令：

systemctl start httpd
要检查httpd服务的状态，可以使用以下命令：



* 取得本机公网ip

~~~shell

curl ifconfig.me

~~~


* 取得相关进程的绝对路径

~~~shell

pgrep -af python| awk '{print $1}'| xargs pwdx



~~~





* Build ubuntu as MacBook os

   White Sur Theme  Gnome Look Like MacOS

  * https://www.youtube.com/watch?v=b3lsY9xTJzE





* 监控系统
  * glances


* Auto generate ssh 


~~~shell

ssh-keygen -t rsa -b 4096 -C "hello@gmail.com" -f ./id_rsa -N "helloworld"
ssh-keygen -t rsa -C "hello@gmail.com"  -N "" -f ./id_rsa
ssh-keygen -t rsa  -N "" -f ~/.ssh/id_rsa
~~~


* 限制网卡速度



#### 限速方案

##### 简单粗暴之ethtool命令

```
以CentOS为例，系统默认自带ethtool命令，使用方法如下：

(1) 查看网卡信息
      ethtool outline-tun0

(2) 使用ethtool命令把千兆网卡降为百兆网卡并关闭自协商
    ethtool -s outline-tun0 speed 100 duplex full autoneg off

(3) 恢复千兆速度并启用自协商
    ethtool -s outline-tun0 speed 1000 duplex full autoneg on

注：此命令会导致服务器outline-tun0临时断网,后自恢复，请谨慎操作。注: 此操作在ESXI虚拟机中无效
```

##### 最便捷之wondershaper

```
(1)google搜索wondershaper rpm下载对应安装包并通过rpm -ivh命令安装（不需要依赖）

(2)命令格式（单位:Kbps）：
   wondershaper 网卡名称 下载速度 上传速度

(3)例如: 我限制outline-tun0网卡下载速度为15Mbit/s,上传速度为10Mbit/s
   wondershaper outline-tun0  15000 10000

(4)取消限速
   wondershaper clear outline-tun0
```

##### 最稳妥限速之交换机端口限速

```
对此不进行赘述
```

#### 限速后测速

```
linux下限速后如何测速？

下载speedtest测速脚本
wget -O speedtest-cli https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py && chmod +x speedtest-cli

执行如下命令等待结果即可
./speedtest-cli
```







### 保持ssh 时候terminal title不变

把远程服务器.bashrc修改如下：

~~~shell

# If this is an xterm set the title to user@host:dir
#case "$TERM" in
#xterm*|rxvt*)
#    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
#    ;;
#*)
#    ;;
#esac
#
# enable color support of ls and also add handy aliases
~~~




### route

ip route show table all





##### system config

~~~shell

sudo systemctl daemon-reload

sudo sysctl -p


~~~





~~~shell

---
- name: Install rsync and synchronize directory
  #hosts: ip100
  hosts: ionet_hosts
  remote_user: root
  tasks:
    - name: Ensure rsync is installed
      apt:
        name: rsync
        state: present

    - name: Synchronize outline directory to /root on remote hosts
      synchronize:

        src: ./create_users.sh
        dest: /root/
        #src: ./io_limit/speedtest
        #dest: /usr/bin/
        archive: yes
        delete: no
~~~

上面delete 选项是什么意思，如果目标主机原先就有/root/create_users.sh这个文件，那么执行上面操作会覆盖原先的么







~~~shell
#docker images
REPOSITORY                          TAG       IMAGE ID       CREATED       SIZE
ionetcontainers/io-worker-monitor   <none>    8cf044ec4c17   4 days ago    1.18GB

上面是运行docker images的显示结果，那么我如何运行docker,当我运行docker ps命令时候可以如下显示，特别是IMAGE那一列的ionetcontainers/io-worker-monitor 这种形式

#docker ps
CONTAINER ID   IMAGE                               COMMAND                  CREATED      STATUS      PORTS     NAMES
cd4b2790cf16   ionetcontainers/io-worker-monitor   "tail -f /dev/null"      4 days ago   Up 4 days             optimistic_
~~~





### Filesystem info



  df -T


##### Add outline to favourite


sudo vim /usr/share/applications

~~~shell

[Desktop Entry]
Encoding=UTF-8
Name=Outline
Comment=Run Outline VPN
Exec=/home/jello/App/Outline-Client.AppImage
Terminal=false
Type=Application
Icon=/home/jello/App/alien.png
StartupNotify=false
#StartupNotify=true
~~~



##### Outline

~/.config/autostart/
rm /etc/systemd/system/outline_proxy_controller.service  /usr/local/sbin/OutlineProxyController






##### Fix vmware network


https://fluentreports.com/blog/?p=717
https://github.com/mkubecek/vmware-host-modules/issues/54


~~~shell

  # cp /tmp/vmnet.tar /usr/lib/vmware/modules/source/vmnet.tar
  # /usr/bin/vmware-modconfig --console --install-all
~~~

