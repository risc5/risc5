# 记录一些常识性的问题

##### 电信、移动等公网IP设置

* 中国联通超级管理员 账户与密码（福建地区）： CUAdmin

  带宽账户：059107xxxx

  带宽密码：666666（默认身份证后面6位）

  tplink account : 15707xxxx

  Wi-Fi 密码：xxx666

  主要思路

  * 猫改成桥接
  * Router拨号
  * 公网ip



##### Enable ubuntu 22.04 ipv6

~~~shell

sudo vim /etc/sysctl.conf

net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
net.ipv6.conf.lo.disable_ipv6=0

#reload
sysctl -p 
~~~





##### Install go

* Go to https://go.dev/dl/

* wget  https://go.dev/dl/go1.21.6.linux-amd64.tar.gz

  

