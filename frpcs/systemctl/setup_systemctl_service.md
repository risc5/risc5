sudo vim /etc/systemd/system/frpc.service
sudo systemctl daemon-reload
systemctl start frpc.service
systemctl enable frpc.service

#search service 
#systemctl list-unit-files |grep frpc
