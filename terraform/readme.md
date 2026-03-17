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
