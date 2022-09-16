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
  
- How to install nginx

  ```shell

  sudo apt install nginx -y

  mkdir -p /var/www/html

  sudo vim /etc/nginx/sites-available/default

  sudo nginx -s reload

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

  
