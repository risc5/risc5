## how to fuck gfw 

> share with other devices in local network



- sudo apt-get install privoxy

- sudo vim /etc/privoxy/config 

```shell
listen-address  0.0.0.0:9999
forward-socks5 / 127.0.0.1:1080 .
```



- Android phone or iphone
  - go to wifi
  - select http proxy to manual  
    - server 192.168.1.113
    - port 9999

- now it work ,share other people is funny


sudo apt-get update 
sudo ufw allow 23135/tcp sudo ufw enable
sudo apt-get install python-pip
sudo apt-get install python-m2crypto
sudo pip install shadowsocks

	sudo nano /etc/shadowsocks.json
	
	{
		"server":"your_server_ip",
		"server_port":23135,
		"local_port":1080,
		"password":"goodbaby",
		"timeout":600,
		"method":"aes-256-cfb"
	}

sudo nano /etc/rc.local

Add the following line to auto start Shadosocks service at boot:

/usr/bin/python /usr/local/bin/ssserver -c /etc/shadowsocks.json -d start

sudo shutdown -r now


https://thetowerinfo.com/setup-shadowsocks-server/

sudo apt update
sudo apt install snapd
sudo snap install outline --edge


https://codediary.net/posts/how-to-setup-an-outline-vpn-server-on-ubuntu/

https://thetowerinfo.com/use-shadowsocks-step-by-step/



## New Fuck GFW

* First install  outline manager then we download the manager ,it will give tips to install server on linode. Like below 

~~~shell

$ sudo -i
$ curl -sS https://get.docker.com/ | sh
$ systemctl start docker
$ systemctl enable docker
$ systemctl status docker
$ wget -qO- https://raw.githubusercontent.com/Jigsaw-Code/outline-server/master/src/server_manager/install_scripts/install_server.sh | bash
~~~

* Install outline-cli

you can use the following command to build the CLI.

~~~shell
git clone https://github.com/Jigsaw-Code/outline-sdk.git

#outline-cli是位于examples下面，没有界面显示的
cd outline-sdk/x/examples/

# with static option may cause compile problem

#go build -o outline-cli  -ldflags="-extldflags=-static" ./outline-cli

go build -o outline-cli  ./outline-cli

sudo ./outline-cli -transport "ss://Y2hhY2hhMjAtaWV0Zi1wb2x5"

~~~
💡 cgo will pull in the C runtime. By default, the C runtime is linked as a dynamic library. Sometimes this can cause problems when running the binary on different versions or distributions of Linux. To avoid this, we have added the -ldflags="-extldflags=-static" option. But if you only need to run the binary on the same machine, you can omit this option.


## ClashX
Ubuntu軟件沒有系統代理，代理端口即是general-->port這個端口


Link: 
* https://portal.shadowsocks.nz/
* https://neverinstall.com/
* Macbook Surge
* Clash https://docs.cfw.lbyczf.com/
* 











### Block Domain



~~~


baidu.com
baidu.cn
sina.com.cn
weibo.com
alibaba.com
tmall.com
jd.com
qq.com
163.com
sohu.com
360.com
tencent.com
youku.com
bilibili.com
douyin.com
ximalaya.com
zhihu.com
dianping.com
pinduoduo.com
meituan.com
alipay.com
taobao.com
suning.com
meilishuo.com
dangdang.com
58.com
cnki.net
cnbeta.com
jike.com
v2ex.com
hiper.com
m.jd.com
xiaomi.com
mi.com
t.co
guba.eastmoney.com
kuaishou.com
toutiao.com
zhifubao.com
iqiyi.com
hao123.com
mop.com
hao123.cn
alipay.cn
auto.sina.com.cn
car.autohome.com.cn
yoka.com
baomihua.com
mama.cn
le.com
tianya.cn
yahoo.com.cn
kankan.com
smzdm.com
xiami.com
aliexpress.com
zhenai.com
coco.cn
letv.com
v.qq.com
91.com
m.baidu.com
wenku.baidu.com
meipai.com
baic.gov.cn
ip138.com
soso.com
mojing.cn
tianjin.gov.cn
xiaochengxu.qq.com
51job.com
kaixin001.com
5i5j.com
gome.com.cn
wanmei.com
ip.360.cn
m.sohu.com
m.sina.com.cn
dianshi.xinhuanet.com
ctcinfotech.com
huya.com
gfan.com
tianjinwe.com
pconline.com.cn
doubin.com
m.renren.com
qidian.com
heziwei.com
cloopen.com
lenovo.com
jiayuan.com
leqi.com
51.la
wanmei.com
zhipin.com
gitee.com
xiaoe-tech.com
carrefour.com.cn
cnsuning.com
51test.net
youxi.la
alizila.com
baotounews.com.cn

~~~

