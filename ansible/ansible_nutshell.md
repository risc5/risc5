https://www.yxingxing.net/archives/ansible-20200208-inventory





**ansible**-playbook playbook.yml --ask-pass



* ansible.cfg

~~~
[defaults]
inventory = ./inventory_ionet
host_key_checking = False


~~~



* inventory_ionet

比如一个远程服务器的群组IP是172.17.0.[2:115]

用户名是root,密码是12345678，请配置相关文件，实现免输入密码登入

~~~shell

[ionet_hosts]
172.17.0.[2:5]


~~~





~~~shell
172.100.102.92 ansible_user=root ansible_password=abcdefg
172.100.102.93 ansible_user=root ansible_password=abcdefg
~~~



比如一个远程服务器的群组IP是172.17.0.[2:115]

~~~shell

---
- name: SSH into multiple hosts and change to home directory
  hosts: ionet_hosts
  remote_user: root
  tasks:
    - name: Change to home directory
      shell: cd /home

    # Optional: Verify the current directory
    - name: Verify current directory
      shell: pwd
      register: result

    - name: Print the current directory
      debug:
        msg: "Current directory is {{ result.stdout }}"



~~~







~~~shell
 解释一下下面register

---
- name: SSH into multiple hosts and run ls -lhtr
  hosts: ionet_hosts
  remote_user: root
  tasks:
    - name: Run ls -lhtr in root directory
      shell: cd /root;ls -lhtr

    # Optional: Capture the output of ls -lhtr
    - name: Capture the output of ls -lhtr
      shell: cd /root;ls -lhtr
      register: ls_output

    - name: Print the output of ls -lhtr
      debug:
        msg: "{{ ls_output.stdout_lines }}"
        
        
~~~





比如一个远程服务器的群组IP是172.17.0.[2:115]，目前需求如下：

1 使用shell模块运行cd /root;ls -lhtr;date 相关命令，并调用debug模块打印出相关信息

2 每隔3分钟，下一个服务器才运行上面命令，比如172.17.0.2开始运行上面命令，那么下一个3分钟172.17.0.3才开始运行，6分钟后172.17.0.4开始运行

playbook.yml文件如下：

~~~shell

---
- name: SSH into multiple hosts and run ls -lhtr
  hosts: ionet_hosts
  remote_user: root
  tasks:
    - name: Run ls -lhtr in root directory
      shell: cd /root;ls -lhtr

    # Optional: Capture the output of ls -lhtr
    - name: Capture the output of ls -lhtr
      shell: cd /root;ls -lhtr
      register: ls_output

    - name: Print the output of ls -lhtr
      debug:
        msg: "{{ ls_output.stdout_lines }}"


~~~









ip140   207 

ip160 76

Ip170 236