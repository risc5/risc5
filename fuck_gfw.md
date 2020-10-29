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
