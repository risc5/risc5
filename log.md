# 常识性问题

### 电信移动公网IP设置

* 中国联通超级管理员 账户与密码（福建地区）： CUAdmin

  带宽账户：059107xxxx

  带宽密码：666666（默认身份证后面6位）

  tplink account : 15707xxxx

  Wi-Fi 密码：xxx666

  主要思路

  * 猫改成桥接
  * Router拨号
  * 公网ip



### Enable ubuntu 22.04 ipv6

~~~shell

sudo vim /etc/sysctl.conf

net.ipv6.conf.all.disable_ipv6=0
net.ipv6.conf.default.disable_ipv6=0
net.ipv6.conf.lo.disable_ipv6=0

#reload
sysctl -p 
~~~





### Install go

* Go to https://go.dev/dl/

* wget  https://go.dev/dl/go1.21.6.linux-amd64.tar.gz

*  rm -rf /usr/local/go && tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz

* export PATH=$PATH:/usr/local/go/bin  



### systemctl


系统启动时，自动启动
* systemctl enable frpc.service 
~~~shell

Restart=always 只要不是通过systemctl stop来停止服务，任何情况下都必须要重启服务，默认值为no

RestartSec=20 重启间隔，比如某次异常后，等待20(s)再进行启动，默认值0.1(s)

StartLimitInterval=0 无限次重启，默认是10秒内如果重启超过5次则不再重启，设置为0表示不限次数重启

~~~



### Install rust

* Todo



### Saltstack vs Ansible



* Todo



### Prometheus & Grafana



* Todo



