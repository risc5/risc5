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
  ```
  
- How to install nginx

  ```shell

  sudo apt install nginx -y

  mkdir -p /var/www/html

  sudo vim /etc/nginx/sites-available/default

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

* Some cmd

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
  ulimit -n 1048576
  
  
  
  ~~~

  

* lsof

~~~shell

lsof是系统管理/安全的尤伯工具。我大多数时候用它来从系统获得与网络连接相关的信息，但那只是这个强大而又鲜为人知的应用的第一步。将这个工具称之为lsof真实名副其实，因为它是指“列出打开文件（lists openfiles）”。而有一点要切记，在Unix中一切（包括网络套接口）都是文件。

https://linux.cn/article-4099-1.html


对于我，lsof替代了netstat和ps的全部工作。它可以带来那些工具所能带来的一切，而且要比那些工具多得多。那么，让我们来看看它的一些基本能力吧：

~~~





*  set  timezone 

  ~~~shell
  #ubuntu 
  dpkg-reconfigure tzdata
  
  ~~~

  



* open files limit



~~~shell

prlimit
ulimit -a
#temp set
ulimit -n 99999
vim /etc/security/limits.conf 



* soft nproc 1048576
* hard nproc 1048576
* soft nofile 1048576
* hard nofile 1048576
root soft nproc 1048576
root hard nproc 1048576
root soft nofile 1048576
root hard nofile 1048576

#本地terminal 打開時候受這個影響
vim /etc/systemd/user.conf

DefaultLimitNOFILE=1048576



vim  /etc/sysctl.conf 

fs.file-max=1048576
vm.max_map_count=1048576




http://www.bictor.com/2022/07/17/ubuntu-16-04-modify-open-file-limits/
~~~



* terminal prompt name

  ~~~
  vim ~/.bashrc
  
  export PS1='[\u@\h \w]$ '
  其中，\u 表示当前用户名   \h 表示当前主机名（hostname） \w 表示当前路径
  
  export PS1='[\u@jello \w]$ '
  ~~~

  
