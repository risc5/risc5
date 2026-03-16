terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "~> 2.13.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}

variable "my_name" { type = string }
variable "state_file" { type = string }

provider "linode" {}

resource "random_password" "root_pass" {
  length           = 14
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

resource "linode_instance" "outline_server" {
  label           = "outline-${var.my_name}"
  image           = "linode/ubuntu24.04"
  region          = "ap-south"
  type            = "g6-nanode-1"
  root_pass       = random_password.root_pass.result
  backups_enabled = false
}

resource "null_resource" "setup_outline" {
  depends_on = [linode_instance.outline_server]

  connection {
    type     = "ssh"
    user     = "root"
    password = random_password.root_pass.result
    host     = linode_instance.outline_server.ip_address
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get install -y -q wget curl python3",
      
      # 1. 第一时间进行中国区连通性测试
      "echo '🚀 正在初始化网络诊断工具...'",
      "wget -O /root/check_ping.py https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/check_ping.py",
      "python3 /root/check_ping.py",

      # 2. 如果你在上一步没有按 Ctrl+C，说明网络没问题，继续部署 Outline
      "echo '🚀 正在安装 Outline 服务端...'",
      "wget -qO- https://raw.githubusercontent.com/risc5/risc5/c3899aafee0da3dd7efb8ef65dec14dc842105f8/setup_outline.sh | bash > /root/outline_install.log 2>&1",
      
      # 3. 部署成功后，生成 SS 链接
      "wget -O /root/gen_ss.py https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/gen_outline_ss.py",
      "python3 /root/gen_ss.py /root/outline_install.log",

      # 4. 打印销毁命令
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🚀 操作完成后，请在本地电脑运行以下命令销毁你的服务器:'",
      "echo 'terraform destroy -state=\"${var.state_file}\" -var=\"my_name=${var.my_name}\" -var=\"state_file=${var.state_file}\" -auto-approve'",
      "echo '------------------------------------------------------------------------------------------------'"
    ]
  }
}
