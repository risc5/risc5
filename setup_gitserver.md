```shell
sudo adduser git
mkdir /opt/code
cd /opt/
chown -R git:git code
su git
ssh-keygen -t rsa
touch .ssh/authorized_keys && chmod 600 .ssh/authorized_keys
cat /tmp/id_rsa.john.pub >> ~/.ssh/authorized_keys //put user rsa pub to auth

// then we can use git account(not develop user account) to clone the git repo 
// without password

git clone git@192.168.1.11:/opt/repo/hellworld/cts.git 


and latest ubuntu use **systemd** to guard daemon 

touch /etc/systemd/system/git-daemon.service

[Unit]
Description=Start Git Daemon

[Service]
ExecStart=/usr/bin/git daemon --reuseaddr --base-path=/srv/git/ /srv/git/

Restart=always
RestartSec=500ms

StandardOutput=syslog
StandardError=syslog
SyslogIdentifier=git-daemon

User=git
Group=git

[Install]
WantedBy=multi-user.target

sudo systemctl daemon-reload
systemctl enable git-daemon 


https://git-scm.com/book/en/v2/Git-on-the-Server-Git-Daemon

add a remote git repo in server（below is setup in git server）：

$ cd /srv/git
$ mkdir project.git
$ cd project.git
$ git init --bare
Initialized empty Git repository in /srv/git/project.git/


add remote server in local :
$ git remote add origin git@192.168.14.72:/opt/repo/at91/doc.git
