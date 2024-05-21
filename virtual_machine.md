# 虚拟机





### 几种虚拟机

* 类型

|                    | 主机系统                                                     | 来宾系统（虚拟机）                                           |
| ------------------ | ------------------------------------------------------------ | ------------------------------------------------------------ |
| VMware Workstation | Windows, Linux                                               | Windows, Linux, Solaris, FreeBSD, OSx86等几乎所有常见的系统  |
| VirtualBox         | Windows, Linux, macOS, Solaris, FreeBSD, eComStation         | DOS, Linux, macOS, FreeBSD, Haiku, OS/2, Solaris, Syllable, Windows, 和 OpenBSD |
| Parallels Desktop  | macOS                                                        | DOS, Windows, Linux, macOS, FreeBSD, OS/2, eComStation, Solaris, Haiku |
| VMware Fusion      | macOS                                                        | Windows, Linux, macOS, Solaris, FreeBSD, OSx86等几乎所有常见的系统 |
| Hyper-V (2012)     | Windows 8, 8.1, 10, and Windows Server 2012 (R2) w/Hyper-V role, Microsoft Hyper-V Server | Windows, FreeBSD, Linux (SUSE 10, RHEL 6, CentOS 6)          |



* Performance



|                    | 功能多不多                     | 对性能的影响大不大 | 操作简不简单       | 客户服务满意度 |
| ------------------ | ------------------------------ | ------------------ | ------------------ | -------------- |
| VMware Workstation | 免费版功能较少；付费版功能挺多 | 比较流畅，小影响   | 操作简单，可设置   | 4.9/5.0        |
| VirtualBox         | 免费版功能也多                 | 影响最大，拖慢     | 简单，入门         | 4.9/5.0        |
| Parallels Desktop  | 附加功能最多                   | 非常流畅，无影响   | 操作简单           | 4.5/5.0        |
| VMware Fusion      | 专业功能最多                   | 非常流畅，小影响   | 操作简单；页面美观 | 4.9/5.0        |
| Hyper-V            | 功能相对缺乏                   | 相当流畅，无影响   | 设置较难           | 4.1/5.0        |





### 虚拟机的几种链接方式





### 5种连接方式

- NAT ：虚拟机可以通过宿主机访问主机能够访问的一切网络，宿主机不能访问虚拟机，虚拟机之间不能访问
  * 比如宿主机的ip为192段，则虚拟机的ip为10段，宿主机访问不了虚拟机，而虚拟机可以访问宿主机
- NAT网络 ：在NAT的基础上，虚拟机之间搭建了局域网，可以实现虚拟机之间的相互访问
- 桥接 ：相当于虚拟机与宿主机连接在同一局域网内，相对于宿主机可见，可以看成是一台连接的宿主机
  * 简单点理解他们都在一个局域网内，ip则由实际的路由器分配
- 内部 ：虚拟机不能连外网
- 仅主机(host-only) ：虚拟机不能连外网，并且不互通



###  Host operating systems




This table lists the supported host operating systems for VMware Workstation Pro 16.x, 17.x and Workstation Player 16.x, 17.x
*Note: VMware Workstation Pro 12.x and above only supports 64-bit host operating systems.*

**Note**: For versions earlier to 16.x see [Supported host operating systems for Workstation Pro 12.x, 14.x, 15.x](https://kb.vmware.com/s/article/2129859)


| **OS Vendor** | **OS Release**                              | **Workstation 16.0** | **Workstation 16.1.0** | **Workstation 16.2.x** | **Workstation 17.0** | **Workstation 17.5** |
| ------------- | ------------------------------------------- | -------------------- | ---------------------- | ---------------------- | -------------------- | -------------------- |
| Canonical     | Ubuntu 22.04                                | -                    | -                      | Yes                    | Yes                  | Yes                  |
| Canonical     | Ubuntu 20.10                                | -                    | Yes                    | Yes                    | -                    | -                    |
| Canonical     | Ubuntu 20.04                                | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Canonical     | Ubuntu 18.04                                | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Canonical     | Ubuntu 16.04                                | Yes                  | Yes                    | Yes                    | -                    | -                    |
|               | Linux Mint 21                               | -                    | -                      | -                      | Yes                  | Yes                  |
|               | Linux Mint 20                               | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Centos        | CentOS 7.x                                  | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Debian        | Debian 12.x                                 | -                    | -                      | -                      | -                    | Yes                  |
| Debian        | Debian 11.x                                 | -                    | -                      | -                      | Yes                  | Yes                  |
| Debian        | Debian 10.x                                 | Yes                  | Yes                    | Yes                    | Yes                  | -                    |
| Debian        | Debian 9.x                                  | Yes                  | Yes                    | Yes                    | -                    | -                    |
| Microsoft     | Windows Server 2022                         | -                    | -                      | -                      | Yes                  | Yes                  |
| Microsoft     | Windows Server 2019                         | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Microsoft     | Windows Server 2016                         | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Microsoft     | Windows Server 2012 R2                      | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Microsoft     | Windows 10                                  | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Microsoft     | Windows 11                                  | -                    | -                      | Yes                    | Yes                  | Yes                  |
| Microsoft     | Windows 8.1 - Update 3                      | Yes                  | Yes                    | Yes                    | -                    | -                    |
| Red Hat       | Fedora 38                                   | -                    | -                      | -                      | -                    | Yes                  |
| Red Hat       | Fedora 37                                   | -                    | -                      | -                      | -                    | Yes                  |
| Red Hat       | Fedora 36                                   | -                    | -                      | -                      | Yes                  | Yes                  |
| Red Hat       | Fedora 35                                   | -                    | -                      | -                      | Yes                  | Yes                  |
| Red Hat       | Fedora 34                                   | -                    | -                      | -                      | Yes                  | Yes                  |
| Red Hat       | Fedora 33                                   | -                    | Yes                    | Yes                    | -                    | -                    |
| Red Hat       | Fedora 32                                   | Yes                  | Yes                    | Yes                    | -                    | -                    |
| Red Hat       | Fedora 31                                   | Yes                  | Yes                    | Yes                    | -                    | -                    |
| Red Hat       | Red Hat Enterprise Linux 9.x                | -                    | -                      | -                      | Yes                  | Yes                  |
| Red Hat       | Red Hat Enterprise Linux 8.3                | -                    | Yes                    | Yes                    | Yes                  | Yes                  |
| Red Hat       | Red Hat Enterprise Linux 8.2                | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Red Hat       | Red Hat Enterprise Linux 8.x                | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| Red Hat       | Red Hat Enterprise Linux 7.x                | Yes                  | Yes                    | Yes                    | Yes                  | Yes                  |
| SUSE          | SUSE Linux Enterprise 15 SP5                | -                    | -                      | -                      | -                    | Yes                  |
| SUSE          | SUSE Linux Enterprise 15 SP3                | -                    | -                      | -                      | Yes                  | -                    |
| SUSE          | SUSE Linux Enterprise 15.x                  | Yes                  | Yes                    | Yes                    | -                    | -                    |
| SUSE          | SUSE Linux Enterprise Server/Desktop 12 SP5 | -                    | -                      | -                      | Yes                  | -                    |
| SUSE          | SUSE Linux Enterprise Server/Desktop 12 SP3 | Yes                  | Yes                    | Yes                    | -                    | -                    |
| SUSE          | openSUSE 15.5                               | -                    | -                      | -                      | -                    | Yes                  |
| SUSE          | openSUSE 15.3                               | -                    | -                      | -                      | Yes                  | -                    |
| SUSE          | openSUSE 15.x                               | Yes                  | Yes                    | Yes                    | -                    | -                    |



### Error Debug



#####  Vmware workstation



* NAT error
  * Could not connect 'Ethernet0' to virtual network '/dev/vmnet8'. More information can be found in the vmware.log file.



在Vmware workstattion Edit---> Virtual network editor--add Nat 

增加下面内容就可以，在host机器上出现/dev/vmnet8



~~~shell
subnet IP: 172.16.175.0
subnet mask :255.255.255.0
Gateway IP： 172.16.175.2
~~~



同时在设备里面增加网络设备



* Can not paste and copy

在安装vmware tool 无效的情况下

~~~


sudo apt-get autoremove open-vm-tools
sudo apt-get install open-vm-tools
sudo apt-get install open-vm-tools-desktop
~~~





* sent link up event



当在nat模式下，host机器有outline的情况下，会不停的出现sent link up event这个信息，同时虚拟机里面的网络是不停的断一下，链一下



这个时候估计需要断开outline或者设置路由了可能



https://www.jianshu.com/p/42c4c90af64a

https://www.vmware.com/resources/compatibility/search.php?deviceCategory=software

 
