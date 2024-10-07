sudo vim /etc/systemd/system/frpc.service
systemctl start frpc.service
systemctl enable frpc.service

#search service 
#systemctl list-unit-files |grep frpc
