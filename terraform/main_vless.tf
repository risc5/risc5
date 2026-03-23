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
  description = "输入你的名字或编号以标记实例 / Enter your name or ID to label the instance:"
}

# 变量 2：用于在输出中显示正确的 state 文件名
variable "state_file" {
  type        = string
  description = "当前部署使用的 state 文件名 (如 1.tfstate) / State file name:"
}

# 变量 3：区域选择变量 (多行提示，包含最新数据中心)
variable "region_choice" {
  type        = string
  description = <<EOF
请选择你要部署的机房区域 (输入对应数字) / Please select a datacenter region (Enter the number):

=== 亚太地区 (Asia Pacific) ===
 1  - 新加坡 1 / Singapore 1 (ap-south)
 2  - 新加坡 2 / Singapore 2 (sg-sin-2)
 3  - 日本东京 1 / Tokyo 1, Japan (ap-northeast)
 4  - 日本东京 3 / Tokyo 3, Japan (jp-tyo-3)
 5  - 日本大阪 / Osaka, Japan (jp-osa)
 6  - 澳大利亚悉尼 / Sydney, Australia (ap-southeast)
 7  - 澳大利亚墨尔本 / Melbourne, Australia (au-mel)
 8  - 印度孟买 / Mumbai, India (ap-west)
 9  - 印度金奈 / Chennai, India (in-maa)
 10 - 印尼雅加达 / Jakarta, Indonesia (id-cgk)

=== 北美洲 (North America) ===
 11 - 加拿大多伦多 / Toronto, Canada (ca-central)
 12 - 美国洛杉矶 / Los Angeles, CA (us-lax)
 13 - 美国西雅图 / Seattle, WA (us-sea)
 14 - 美国弗里蒙特(旧金山湾区) / Fremont, CA (us-west)
 15 - 美国达拉斯 / Dallas, TX (us-central)
 16 - 美国芝加哥 / Chicago, IL (us-ord)
 17 - 美国亚特兰大 / Atlanta, GA (us-southeast)
 18 - 美国迈阿密 / Miami, FL (us-mia)
 19 - 美国华盛顿特区 / Washington, DC (us-iad)
 20 - 美国纽瓦克(纽约周边) / Newark, NJ (us-east)

=== 欧洲 (Europe) ===
 21 - 英国伦敦 / London, UK (eu-west)
 22 - 德国法兰克福 / Frankfurt, DE (eu-central)
 23 - 法国巴黎 / Paris, FR (fr-par)
 24 - 荷兰阿姆斯特丹 / Amsterdam, NL (nl-ams)
 25 - 瑞典斯德哥尔摩 / Stockholm, SE (se-sto)
 26 - 西班牙马德里 / Madrid, ES (es-mad)
 27 - 意大利米兰 / Milan, IT (it-mil)

=== 南美洲 (South America) ===
 28 - 巴西圣保罗 / Sao Paulo, BR (br-gru)

请输入数字 (如输入不在列表内的数字，将默认选择 1 新加坡):
EOF
}

# 本地变量：将用户输入的数字映射为 Linode 的真实 Region ID
locals {
  region_map = {
    "1"  = "ap-south"
    "2"  = "sg-sin-2"
    "3"  = "ap-northeast"
    "4"  = "jp-tyo-3"
    "5"  = "jp-osa"
    "6"  = "ap-southeast"
    "7"  = "au-mel"
    "8"  = "ap-west"
    "9"  = "in-maa"
    "10" = "id-cgk"
    "11" = "ca-central"
    "12" = "us-lax"
    "13" = "us-sea"
    "14" = "us-west"
    "15" = "us-central"
    "16" = "us-ord"
    "17" = "us-southeast"
    "18" = "us-mia"
    "19" = "us-iad"
    "20" = "us-east"
    "21" = "eu-west"
    "22" = "eu-central"
    "23" = "fr-par"
    "24" = "nl-ams"
    "25" = "se-sto"
    "26" = "es-mad"
    "27" = "it-mil"
    "28" = "br-gru"
  }
  # lookup 函数：寻找匹配的数字，如果找不到，默认使用 "ap-south" (新加坡 1)
  selected_region = lookup(local.region_map, var.region_choice, "ap-south")
}

provider "linode" {}

# 1. 生成 14 位随机密码 (含特殊字符)
resource "random_password" "root_pass" {
  length           = 14
  special          = true
  override_special = "!@#$%^&*()-_=+"
}

# 2. 部署 Linode $5 节点 (Ubuntu 24.04)
resource "linode_instance" "proxy_server" {
  label           = "xray-${var.my_name}"
  image           = "linode/ubuntu24.04"
  region          = local.selected_region # 使用用户选择的区域
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

      # 2. 运行 Xray VLESS-Reality 部署脚本
      "echo '🚀 正在安装防封锁 Xray 服务端...'",
      "wget -qO- https://raw.githubusercontent.com/risc5/risc5/refs/heads/master/terraform/setup_xray_reality.sh | bash",
      
      # 3. 最终汇总打印所有配置信息
      "echo '================================================================================================'",
      "echo '🖥️  服务器 IP: ${linode_instance.proxy_server.ip_address} (机房: ${local.selected_region})'",
      "echo '🔑 Root 密码: ${nonsensitive(random_password.root_pass.result)}'",
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🔗 VLESS 链接 (通用):'",
      "cat /root/vless_link.txt",
      "echo ''",
      "echo '📦 Clash Verge 配置 (请确保使用 Mihomo/Meta 内核):'",
      "cat /root/clash_config.txt",
      "echo '------------------------------------------------------------------------------------------------'",
      "echo '🚀 操作完成后，请在本地电脑运行以下命令销毁你的服务器:'",
      "echo 'terraform destroy -state=\"${var.state_file}\" -var=\"my_name=${var.my_name}\" -var=\"state_file=${var.state_file}\" -var=\"region_choice=${var.region_choice}\" -auto-approve'",
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

output "Server_Region" {
  value = local.selected_region
}

output "Root_Password" {
  # 使用 nonsensitive 强行解除保护，以便直接打印密码
  value = nonsensitive(random_password.root_pass.result)
}
