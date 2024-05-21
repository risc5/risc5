# HWE和GA



Ubuntu 中的 HWE（Hardware Enablement）和 GA（General Availability）版本是针对不同用户群体的两种内核版本。



**GA 版本** 是指 **通用可用版本**，它经过了全面测试，适用于大多数用户。GA 版本通常在新的 Ubuntu 版本发布时提供，并提供稳定的内核体验。



**HWE 版本** 是指 **硬件支持版本**，它包含了对最新硬件的支持，例如新发布的 CPU、GPU 和其他设备。HWE 版本通常在 GA 版本发布后几个月提供，旨在为使用最新硬件的用户提供最佳性能和兼容性。



**以下是 HWE 和 GA 版本之间的一些主要区别：**



- 

- **稳定性:** GA 版本通常比 HWE 版本更稳定，因为它经过了更长时间的测试和验证。
- 

- **硬件支持:** HWE 版本提供对最新硬件的支持，而 GA 版本可能不支持。
- 

- **安全性:** HWE 版本通常包含最新的安全补丁，因为它们比 GA 版本更新更频繁。
- 

- **风险:** HWE 版本可能比 GA 版本更不稳定，因为它包含了更新的代码，尚未经过全面测试。







### Kernel Version



* zen
* liquorix 
* xanmod 



Zen、Liquorix 和 Xanmod 都是针对 Linux 的自定义内核，旨在提高性能、稳定性和兼容性。它们都基于官方的 Linux 内核源代码，并包含各种额外的补丁和功能。



**以下是这三个内核的区别：**



**Zen 内核** 是由 Google 开发的，它旨在为各种设备提供良好的性能和稳定性。它包含了一些针对特定硬件平台的优化，并且还包含一些提高电源效率的功能。



**Liquorix 内核** 是由 Michael Dementz 开发的，它旨在为桌面和游戏用户提供最佳性能。它包含了大量针对 CPU 调度、内存管理和 I/O 性能的优化。



**Xanmod 内核** 是由 Xanxus 开发的，它旨在为用户提供可定制、高性能的内核体验。它包含了来自 Zen 和 Liquorix 内核的补丁，以及一些额外的功能，例如改进的 CPU 调度程序和文件系统支持。



**以下是这三个内核的详细比较：**





| 特性   | Zen                                                | Liquorix                                     | Xanmod                                                       |
| ------ | -------------------------------------------------- | -------------------------------------------- | ------------------------------------------------------------ |
| 开发者 | Google                                             | Michael Dementz                              | Xanxus                                                       |
| 目标   | 通用性能和稳定性                                   | 桌面和游戏性能                               | 可定制的高性能                                               |
| 补丁   | 一些针对特定硬件平台的优化，以及提高电源效率的功能 | 大量针对 CPU 调度、内存管理和 I/O 性能的优化 | 来自 Zen 和 Liquorix 内核的补丁，以及一些额外的功能，例如改进的 CPU 调度程序和文件系统支持 |
| 优点   | 良好的整体性能和稳定性                             | 适用于需要高性能的桌面和游戏用户             | 高度可定制，可根据您的特定需求进行调整                       |
| 缺点   | 可能不如其他两个内核那样专注于特定用例             | 可能比其他两个内核更不稳定                   | 编译和配置可能更复杂                                         |







**总体而言，Zen 内核是一个不错的选择，如果您正在寻找一个通用内核，它可以提供良好的性能和稳定性。Liquorix 内核是需要高性能的桌面和游戏用户的不错选择。Xanmod 内核是寻求高度可定制且可根据其特定需求进行调整的内核的用户的不錯选择。**



### Remove Kernel

>When install use make install





~~~
rm -rf /boot/vmlinuz-6.9.0-rc4-dirty
rm -rf /boot/initrd.img-6.9.0-rc4-dirty
rm -rf /boot/System.map-6.9.0-rc4-dirty
rm -rf /boot/config-6.9.0-rc4-dirty
rm -rf /lib/modules/6.9.0-rc4-dirty
sleep 10
update-grub2

~~~





### ubuntu kernel release cycle



![image-20240509165931856](/Users/jello/Library/Application Support/typora-user-images/image-20240509165931856.png)



~~~shell


git clone git://git.launchpad.net/~ubuntu-kernel/ubuntu/+source/linux/+git/jammy


~~~





https://ubuntu.com/kernel/lifecycle



| [ ubuntu-22.04-desktop-amd64.iso](https://old-releases.ubuntu.com/releases/22.04/ubuntu-22.04-desktop-amd64.iso) | 2022-04-19 10:25 | 3.4G |      |
| ------------------------------------------------------------ | ---------------- | ---- | ---- |
|                                                              |                  |      |      |
|                                                              |                  |      |      |
|                                                              |                  |      |      |