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

resource "linode_instance" "proxy_server" {
  label           = "xray-${var.my_name}"
  image           = "linode/ubuntu24.04"
  region          = "ap-south"
  type            = "g6-nanode-1"
  root_pass       = random_password.root_pass.result
  backups_enabled = false
}

resource "null_resource" "setup_proxy" {
  depends_on = [linode_instance.proxy_server]

  connection {
    type     = "ssh"
    user     = "root"
    password = random_password.root_pass.result
    host     = linode_instance.proxy_server.ip_address
    timeout  = "5m"
  }

  provisioner "remote-exec" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "apt-get update -q -y && apt-get install -y -q wget curl python3 openssl",

      # 1. 运行中国区连通性诊断 (如果失败，你有 10 秒钟按 Ctrl+C 中断)
      "echo '🚀 正在初始化网络诊断工具...'",
      "wget -O /root/check_ping.py https://raw.githubusercontent.com/risc5/risc5/main/check_ping.py",
      "python3 /root/check_ping.py",

      # 2. 部署极难被封锁的 Xray VLESS-Reality
      "echo '🚀 网络通畅，正在安装防封锁 Xray 服务端...'",
      "wget -qO-  https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/setup_xray_reality.sh | bash",

      # 3. 打印配置信息与销毁命令
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🎉 你的标准 VLESS-REALITY 客户端连接地址：'",
      "cat /root/vless_link.txt",
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🚀 操作完成后，请在本地电脑运行以下命令销毁你的服务器:'",
      "echo 'terraform destroy -state=\"${var.state_file}\" -var=\"my_name=${var.my_name}\" -var=\"state_file=${var.state_file}\" -auto-approve'",
      "echo '------------------------------------------------------------------------------------------------'"
    ]
  }
}
