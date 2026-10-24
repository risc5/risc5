~~~
export LINODE_TOKEN="你的_Linode_API_Token"
terraform init
terraform apply -state="1.tfstate" -var="my_name=sg-jello1" -var="state_file=1.tfstate" -auto-approve
terraform destroy -state="1.tfstate" -var="my_name=sg-jello1" -var="state_file=1.tfstate" -auto-approve



terraform apply -state="2.tfstate" -var="my_name=sg-jello2" -var="state_file=2.tfstate" -auto-approve


terraform output -state="1.tfstate" -raw root_password

terraform apply -auto-approve

🚀 操作完成后，请在本地电脑运行以下命令销毁你的服务器:
terraform apply -state="1.tfstate" -var="my_name=jello-1" -auto-approve



terraform destroy -state="1.tfstate" -var="my_name=jello-2" -auto-approve
~~~





### Windows Install

~~~
打开powershell
[System.Environment]::SetEnvironmentVariable("LINODE_TOKEN", "xxxToken", "User")


安装 https://github.com/chocolatey/ChocolateyGUI/releases/download/3.0.0/ChocolateyGUI.msi
在里面安装 terraform 
~~~





### 不需要关闭本地代理

1. **Globalping 调度中国境内探针**： 指令要求 Globalping 在**中国大陆境内（CN）**随机挑选 3 个探测节点（探针）。
2. **中国节点反向 Ping 服务器**： 这 3 个位于中国大陆境内的探针会**从中国境内发起 ICMP Ping，测试能否连通你的这台 Linode 服务器**。
3. **回传结论**： 服务器轮询拿到这 3 个中国探针的丢包率（loss）。只要丢包率不是 100%，就证明**当前这台服务器的 IP 并没有被 阻断**，国内可以直连。