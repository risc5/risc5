#!/bin/bash
# 一键安装 Xray 并配置 VLESS-Reality 协议

echo "🚀 开始安装 Xray 核心..."
# 官方脚本安装 Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root

# 生成必须的密钥和 UUID
UUID=$(xray uuid)
KEYS=$(xray x25519)
PRI_KEY=$(echo "$KEYS" | grep "Private key" | awk '{print $3}')
PUB_KEY=$(echo "$KEYS" | grep "Public key" | awk '{print $3}')
SHORT_ID=$(openssl rand -hex 4) # 生成 8 位字符的 shortId
SERVER_IP=$(curl -s https://api.ipify.org)

# 伪装目标网站 (SNI)。必须是支持 TLSv1.3 且国内能访问的海外网站
# 这里默认伪装成苹果系统更新域名
DEST="swdist.apple.com:443"
SNI="swdist.apple.com"

echo "⚙️ 正在生成 Xray 配置文件..."
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "$UUID",
            "flow": "xtls-rprx-vision"
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "tcp",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "dest": "$DEST",
          "xver": 0,
          "serverNames": ["$SNI"],
          "privateKey": "$PRI_KEY",
          "shortIds": ["$SHORT_ID"]
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}
EOF

# 重启并设置开机启动
systemctl restart xray
systemctl enable xray

# 生成标准的 vless:// 客户端分享链接
VLESS_LINK="vless://$UUID@$SERVER_IP:443?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$SNI&fp=chrome&pbk=$PUB_KEY&sid=$SHORT_ID&type=tcp&headerType=none#Linode-Xray"

echo "=========================================================="
echo "🎉 你的高防封 VLESS-REALITY 客户端链接已生成："
echo "$VLESS_LINK"
echo "=========================================================="

# 将链接保存到一个文件中，方便 Terraform 提取
echo "$VLESS_LINK" > /root/vless_link.txt
