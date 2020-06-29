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
