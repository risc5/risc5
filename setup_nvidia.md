# How To Install GTX 960 On Ubuntu 20.04



### 禁用Ubuntu 自带显卡驱动



sudo vim /etc/modprobe.d/blacklist-nouveau.conf

blacklist nouveau
options nouveau modeset=0



<span  style="color: #ff1bce; ">安装NVIDIA-Linux-x86_64-535.161.07.run这类驱动文件的时候，会有个选项创建类似上面的一个文件，里面内容是一样的</span> 

### Ubuntu-drivers介绍



Ubuntu-drivers的主要作用是简化在Ubuntu系统上安装和管理显卡驱动程序的过程。

它提供以下功能：

- **自动检测显卡类型并建议合适的驱动程序：** 当您首次启动Ubuntu系统时，ubuntu-drivers会自动检测您的显卡类型并建议安装合适的驱动程序。
- **轻松安装驱动程序：** ubuntu-drivers可以轻松安装建议的驱动程序，无需您手动下载和安装。
- **维护驱动程序：** ubuntu-drivers可以自动检查驱动程序更新并通知您安装。它还可以帮助您解决驱动程序问题。
- **支持多种显卡类型：** ubuntu-drivers支持各种显卡类型，包括Nvidia、AMD和Intel显卡。



* 列出相应的显卡驱动
  *  sudo ubuntu-drivers devices

~~~shell

# sudo ubuntu-drivers devices

== /sys/devices/pci0000:20/0000:20:03.1/0000:21:00.0 ==
modalias : pci:v000010DEd00001401sv000019DAsd00004378bc03sc00i00
vendor   : NVIDIA Corporation
model    : GM206 [GeForce GTX 960]
manual_install: True
driver   : nvidia-driver-470 - distro non-free
driver   : nvidia-driver-418-server - distro non-free
driver   : nvidia-driver-450-server - distro non-free
driver   : nvidia-driver-535-server - distro non-free
driver   : nvidia-driver-535 - distro non-free recommended
driver   : nvidia-driver-470-server - distro non-free
driver   : nvidia-driver-545 - distro non-free
driver   : nvidia-driver-390 - distro non-free
driver   : xserver-xorg-video-nouveau - distro free builtin
~~~

* NVIDIA Driver 535 Server Open： 这是专为服务器环境设计的开放版本的NVIDIA驱动程序，它具有一些特定于服务器的功能或优化，以提供更好的性能和稳定性。

* NVIDIA Driver 535： 这是通用版本的NVIDIA驱动程序，适用于大多数NVIDIA显卡和桌面/笔记本电脑系统，它能提供广泛的兼容性和功能，并支持各种应用程序和游戏。

* NVIDIA Driver 535 Open： 这是开源版本的NVIDIA驱动程序，针对那些希望在开放源代码环境下自定义和修改驱动程序的用户，它能提供更多的灵活性和可定制性。

### Install nvidia-smi

~~~shell
sudo apt install linux-headers-$(uname -r)
sudo ubuntu-drivers  install nvidia-driver-535
sudo apt-get install nvidia-driver-535
#或则下面
sudo ubuntu-drivers install nvidia:535
sudo apt install nvidia-dkms-535

~~~





### Checkout driver 

Checkout driver  whether is installer

* sudo nvidia-smi

  
  
  ~~~shell
  Wed May  1 20:56:23 2024       
  +---------------------------------------------------------------------------------------+
  | NVIDIA-SMI 535.161.07             Driver Version: 535.161.07   CUDA Version: 12.2     |
  |-----------------------------------------+----------------------+----------------------+
  | GPU  Name                 Persistence-M | Bus-Id        Disp.A | Volatile Uncorr. ECC |
  | Fan  Temp   Perf          Pwr:Usage/Cap |         Memory-Usage | GPU-Util  Compute M. |
  |                                         |                      |               MIG M. |
  |=========================================+======================+======================|
  |   0  NVIDIA GeForce GTX 960         Off | 00000000:21:00.0 Off |                  N/A |
  | 39%   37C    P8              14W / 120W |    408MiB /  4096MiB |      0%      Default |
  |                                         |                      |                  N/A |
  +-----------------------------------------+----------------------+----------------------+
                                                                                           
  +---------------------------------------------------------------------------------------+
  | Processes:                                                                            |
  |  GPU   GI   CI        PID   Type   Process name                            GPU Memory |
  |        ID   ID                                                             Usage      |
  |=======================================================================================|
  |    0   N/A  N/A      4847      G   /usr/lib/xorg/Xorg                          270MiB |
  |    0   N/A  N/A      5014      G   /usr/bin/gnome-shell                         46MiB |
  |    0   N/A  N/A      5699      G   ...ures=SpareRendererForSitePerProcess       15MiB |
  |    0   N/A  N/A      7950      G   ...seed-version=20240429-180218.438000       65MiB |
  |    0   N/A  N/A     21202      G   gnome-control-center                          0MiB |
  +---------------------------------------------------------------------------------------+
  

  ~~~

   显示如上则代表驱动既可用于加速计算与显示，Processes部分代表显示功能。说明显卡正常工作了

  
  
  第一栏的Fan：N/A是风扇转速，从0到100%之间变动。有的设备不会返回转速，因为它不依赖风扇冷却而是通过其他外设保持低温。
  第二栏的Temp：是温度，单位摄氏度。
  第三栏的Perf：是性能状态，从P0到P12，P0表示最大性能，P12表示状态最小性能。
  第四栏下方的Pwr：是能耗，上方的Persistence-M：是持续模式的状态，持续模式虽然耗能大，但是在新的GPU应用启动时，花费的时间更少，这里显示的是off的状态。
  第五栏的Bus-Id是涉及GPU总线的东西，domain​ ​bus:device.function
  第六栏的Disp.A是Display Active，表示GPU的显示是否初始化。
  第五第六栏下方的Memory Usage是显存使用率。
  第七栏是浮动的GPU利用率。
  第八栏上方是关于ECC的东西。
  第八栏下方Compute M是计算模式。


~~~shell
#需要加sudo， 不加sudo可能存在bugs
sudo dkms status
sudo nvidia-smi

sudo prime-select nvidia 

~~~







### dpkg 用法





* dpkp -l

  * dpkg -l

    ~~~shell
    # dpkg -l
    Desired=Unknown/Install/Remove/Purge/Hold
    | Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
    |/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
    
    
    ~~~

    该命令每行输出中的第一列 `ii` 表示软件包的安装和配置状态，其格式如下：
    `期望状态|当前状态|错误`
    其中**期望状态**有以下几种

    - u：即 unknown，软件包未安装且用户未请求安装
    - i：即 install，用户请求安装该软件包
    - r：即 remove，用户请求卸载该软件包
    - p：即 purge，用户请求卸载该软件包并清理配置文件
    - h：即 hold，用户请求保持续当前软件包版本

    **当前状态** 有以下几种：

    - n：即 not-installed，软件包未安装
    - i：即 installed，软件包已安装并完成配置
    - c：即 config-files，软件包已经被卸载，但是其配置文件未清理
    - u：即 unpacked，软件包已经被解压缩，但还未配置
    - f：即 half-configured，配置软件包时出现错误
    - w：即 triggers-awaited，触发器等待
    - t：即 triggers-pending，触发器未决

    **错误状态** 有以下几种：

    - h：软件包被强制保持
    - r：即 reinstall-required，需要卸载并重新安装
    - x：软件包被破坏

    

    <span  style="color: #ff1bce; ">因此</span>

    `ii` 表示该软件需要安装且已经安装，没有出现错误；
    `iu` 表示已经安装该软件，但未正确配置；

     rc  表示该软件已经被删除，但配置文件未清理。

    

    

### Find Nvidia

  

* 找到已经安装的Nvidia包

~~~shell
  # dpkg -l|grep nvidia|grep ii
ii  libnvidia-cfg1-535-server:amd64                  535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA binary OpenGL/GLX configuration library
ii  libnvidia-common-535-server                      535.161.08-0ubuntu2.22.04.1             all          Shared files used by the NVIDIA libraries
ii  libnvidia-compute-535-server:amd64               535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA libcompute package
ii  libnvidia-compute-535-server:i386                535.161.08-0ubuntu2.22.04.1             i386         NVIDIA libcompute package
ii  libnvidia-decode-535-server:amd64                535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA Video Decoding runtime libraries
ii  libnvidia-decode-535-server:i386                 535.161.08-0ubuntu2.22.04.1             i386         NVIDIA Video Decoding runtime libraries
ii  libnvidia-encode-535-server:amd64                535.161.08-0ubuntu2.22.04.1             amd64        NVENC Video Encoding runtime library
ii  libnvidia-encode-535-server:i386                 535.161.08-0ubuntu2.22.04.1             i386         NVENC Video Encoding runtime library
ii  libnvidia-extra-535-server:amd64                 535.161.08-0ubuntu2.22.04.1             amd64        Extra libraries for the NVIDIA Server Driver
ii  libnvidia-fbc1-535-server:amd64                  535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA OpenGL-based Framebuffer Capture runtime library
ii  libnvidia-fbc1-535-server:i386                   535.161.08-0ubuntu2.22.04.1             i386         NVIDIA OpenGL-based Framebuffer Capture runtime library
ii  libnvidia-gl-535-server:amd64                    535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA OpenGL/GLX/EGL/GLES GLVND libraries and Vulkan ICD
ii  libnvidia-gl-535-server:i386                     535.161.08-0ubuntu2.22.04.1             i386         NVIDIA OpenGL/GLX/EGL/GLES GLVND libraries and Vulkan ICD
ii  linux-objects-nvidia-535-server-6.5.0-34-generic 6.5.0-34.34~22.04.2                     amd64        Linux kernel nvidia modules for version 6.5.0-34 (objects)
ii  linux-signatures-nvidia-6.5.0-34-generic         6.5.0-34.34~22.04.2                     amd64        Linux kernel signatures for nvidia modules for version 6.5.0-34-generic
ii  nvidia-compute-utils-535-server                  535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA compute utilities
ii  nvidia-dkms-535                                  535.171.04-0ubuntu0.22.04.1             amd64        NVIDIA DKMS package
ii  nvidia-firmware-535-535.171.04                   535.171.04-0ubuntu0.22.04.1             amd64        Firmware files used by the kernel module
ii  nvidia-firmware-535-server-535.161.08            535.161.08-0ubuntu2.22.04.1             amd64        Firmware files used by the kernel module
ii  nvidia-kernel-common-535                         535.171.04-0ubuntu0.22.04.1             amd64        Shared files used with the kernel module
ii  nvidia-kernel-source-535                         535.171.04-0ubuntu0.22.04.1             amd64        NVIDIA kernel source package
ii  nvidia-utils-535-server                          535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA Server Driver support binaries
ii  xserver-xorg-video-nvidia-535-server             535.161.08-0ubuntu2.22.04.1             amd64        NVIDIA binary Xorg driver




~~~



* 删除之

  ~~~shell
  sudo apt-get remove -y $(dpkg -l |grep nvidia|grep ^ii| awk '{print $2}')
  ~~~

* <span  style="color: #ff1bce; ">因为要重新安装Nvidia驱动，必须要删除干净，比如像上面由于用ubuntu 命令去安装，或则各个不同版本的ubuntu与Nvidia这个闭源的驱动存在相关不兼容性。或者说N公司对Ubuntu支持不大友好</span> 

* <span  style="color: #ff1bce; ">删除干净后，去官方直接下载个NVIDIA-Linux-x86_64-535.161.07.run ，直接安装就好了</span> 





### 禁用集成显卡

Dell720 需要在 BIOS 里 **直接禁用集成显卡**，这样 Ubuntu 才能使用 NVIDIA 独立显卡。

方法：

1. 进入 BIOS（通常是按 `F2` 或 `Delete` 进入）
2. 找到Int开头
3. 选择 **Disable Integrated Graphics** 与 **4G**
4. 保存并重启

这样 Ubuntu 就不会使用集成显卡。





### 切换到独立显卡



<span  style="color: #ff1bce; ">安装 nvidia- 相关命令</span>,nvidia-prime 

~~~shell
# nvidia-prime 包含了prime-select nvidia相关命令
sudo apt install nvidia-prime 
sudo prime-select query


# 使用 prime-select 切换到 NVIDIA 独显
sudo prime-select nvidia
sudo reboot

~~~





还有一种方法是修改 Xorg（openai），也可以切换到独立显卡

编辑（或新建）配置文件：/etc/X11/xorg.conf

```
bash


CopyEdit
sudo nano /etc/X11/xorg.conf
```

添加以下内容：

```
conf


CopyEdit
Section "Device"
    Identifier "NVIDIA Card"
    Driver "nvidia"
    BusID "PCI:1:0:0"
EndSection
```

其中 `BusID` 需要与你的独显对应，可以用以下命令查询：

```
bash


CopyEdit
lspci | grep -i nvidia
```

例如：

```
yaml


CopyEdit
01:00.0 VGA compatible controller: NVIDIA Corporation TU106 [GeForce RTX 2060] (rev a1)
```

则 `BusID` 应该写成：

```
conf


CopyEdit
BusID "PCI:1:0:0"
```

然后保存文件并重启：

```
bash


CopyEdit
sudo reboot
```







**其他命令**

~~~shell



sudo lshw -numeric -C display
journalctl -b0 |grep gdm-x-session >journal.txt
lspci|grep -i vga



~~~





### GT740

安装下面文件

[NVIDIA-Linux-x86_64-470.256.02.run](https://us.download.nvidia.com/XFree86/Linux-x86_64/470.256.02/NVIDIA-Linux-x86_64-470.256.02.run)