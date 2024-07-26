

##### Auto push pwd to remote host

~~~shell
for ip in $(seq 2 115); do
    sshpass -p '12345678' ssh-copy-id -o StrictHostKeyChecking=no -i /path/to/your/ssh_keys/id_rsa.pub root@172.17.0.$ip
    sshpass -p '12345678' ssh-copy-id -o StrictHostKeyChecking=no root@172.17.0.$ip
done
~~~
