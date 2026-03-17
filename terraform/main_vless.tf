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

# 变量 1：用于标记服务器 Label (如 vless-1)
variable "my_name" {
  type        = string
  description = "输入你的名字或编号以标记实例"
}

# 变量 2：用于在输出中显示正确的 state 文件名
variable "state_file" {
  type        = string
  description = "当前部署使用的 state 文件名 (如 1.tfstate)"
}

provider "linode" {}

# 1. 生成 14 位随机密码 (含特殊字符)
resource "random_password" "root_pass" {
  length           = 14
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

# 2. 部署 Linode 新加坡 $5 节点 (Ubuntu 24.04)
resource "linode_instance" "proxy_server" {
  label           = "xray-${var.my_name}"
  image           = "linode/ubuntu24.04"
  region          = "ap-south"
  type            = "g6-nanode-1"
  root_pass       = random_password.root_pass.result
  backups_enabled = false # 确保最省钱
}

# 3. SSH 登录并执行 GitHub 自动化脚本
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
      
      # 1. 下载并运行中国区连通性诊断 (Globalping)
      "echo '🚀 正在初始化网络诊断工具...'",
      "wget -qO /root/check_ping.py https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/check_ping.py",
      "python3 /root/check_ping.py",

      # 2. 运行 Xray VLESS-Reality 部署脚本 (已修复密钥提取逻辑)
      "echo '🚀 正在安装防封锁 Xray 服务端...'",
      "wget -qO- https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/setup_xray_reality.sh | bash",
      
      # 3. 最终汇总打印所有配置信息
      "echo '================================================================================================'",
      "echo '🖥️  服务器 IP: ${linode_instance.proxy_server.ip_address}'",
      "echo '🔑 Root 密码: ${nonsensitive(random_password.root_pass.result)}'",
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🔗 VLESS 链接 (通用):'",
      "cat /root/vless_link.txt",
      "echo ''",
      "echo '📦 Clash Verge 配置 (请确保使用 Mihomo/Meta 内核):'",
      "cat /root/clash_config.txt",
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🚀 操作完成后，请在本地电脑运行以下命令销毁你的服务器:'",
      "echo 'terraform destroy -state=\"${var.state_file}\" -var=\"my_name=${var.my_name}\" -var=\"state_file=${var.state_file}\" -auto-approve'",
      "echo '================================================================================================'"
    ]
  }
}

# ----------------------------------------------------------------------
# 屏幕底部的原生 Output 打印
# ----------------------------------------------------------------------

output "Server_IP" {
  value = linode_instance.proxy_server.ip_address
}

output "Root_Password" {
  # 使用 nonsensitive 强行解除保护，以便直接打印密码
  value = nonsensitive(random_password.root_pass.result)
}
