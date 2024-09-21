# How To Use Ansible Tool

### Install Ansible

apt-get install sshpass 




0x064aB0b277Df1e04625C44c4F950d1A9Ada3706F

/root/.ssh/id_rsa





请写一个ansible脚本 ，

1 实现ssh自动登入172.17.0.2-172.17.0.2.45的机器，这些机器登入密码都是12345678

2 这些机器都是ubuntu系统，登入到这些系统后cd 到home目录





用户名是root,请重新输出上述所有相关文件inventory_ionet， playbook.yml与ansible.cfg与相关命令



运行上面命令后，有类似如下输出

ok: [172.17.0.3] => {

  "msg": "total 0\ndrwxr-xr-x 1 root root 144 May 21 20:32 bin"

}

请改成人类容易阅读的格式，其中\n没有起作用哦





 我对playbook.yml 做如下修改

~~~shell
---
- name: SSH into multiple hosts and run ls -lh 
  hosts: ionet_hosts
  remote_user: root
  tasks:
    - name: Run ls -lh in root directory
      command: cd /root 

    # Optional: Capture the output of ls -lh
    - name: Capture the output of ls -lh 
      command: ls -lh /root
      register: ls_output

    - name: Print the output of ls -lh 
      debug:
        msg: "{{ ls_output.stdout_lines }}"


~~~



产生了错误

"changed": false, "cmd": "cd /root", "msg": "[Errno 2] No such file or directory





建立一个新的playbook.yml ，实现如下功能：

1 在/root目录底下新建立一个名称为hello_ansible的目录

2 并在hello_ansible目录下面，建立一个文件名为world.md的文件，里面的内容为hello world





再建立一个新的playbook.yml ，实现如下功能：

1 把本地服务器/ansible/test1/meta.bin 文件上传到远程所有服务器（ionet_hosts）/root/hello_ansible目录下面





再建立一个新的playbook.yml ，在本地服务器与远程所有服务器（ionet_hosts）的id_rsa， id_rsa.pub之前都已经生成的前提条件下，实现如下功能：

1  由于目前还需要每次手头输入密码，即 带“ --ask-pass”参数，然后输入密码。现在我想免密码登入，如何实现这个功能呢







在上面的基础上，因为已经可以自动登入。不必再通过“ --ask-pass”参数，输入密码了，那么这行命令 ansible-playbook playbook.yml --ask-pass请做相应调整

1 在/root目录底下新建立一个名称为hello_ansible的目录

2 并在hello_ansible目录下面，建立一个文件名为world.md的文件，里面的内容为hello world







Ansible 提供了许多模块，用于执行各种任务。以下是一些常用的 Ansible 模块：

1. **command**: 在远程主机上执行命令。
2. **shell**: 在远程主机上执行 shell 命令。
3. **copy**: 将文件从控制节点复制到远程主机。
4. **file**: 在远程主机上管理文件和目录。
5. **template**: 使用 Jinja2 模板在远程主机上生成文件。
6. **lineinfile**: 在文件中添加、删除或修改一行。
7. **yum/apt**: 在远程主机上安装、升级或删除软件包。
8. **service**: 启动、停止或重新启动服务。
9. **user**: 管理系统用户。
10. **group**: 管理系统用户组。
11. **cron**: 管理定时任务。
12. **debug**: 打印调试信息。
13. **wait_for**: 等待特定条件的达成。
14. **ping**: 检查远程主机是否可达。
15. **setup**: 收集远程主机的系统信息。







再建立一个新的playbook_ping.yml ， 用来实现ping模块的用法
