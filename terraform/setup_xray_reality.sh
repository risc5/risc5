#!/bin/bash
# 一键安装 Xray VLESS-Reality (行号精准提取版)

export DEBIAN_FRONTEND=noninteractive
apt-get update -q -y && apt-get install -q -y unzip openssl curl

# 1. 安装 Xray
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root

XRAY_CMD="/usr/local/bin/xray"
UUID=$($XRAY_CMD uuid)

# 2. 【核心修改】不再搜关键字，直接按输出顺序取值
# x25519 执行一次，输出两行有效信息
KEYS_OUT=$($XRAY_CMD x25519)

# 第一串 Base64 字符是私钥
PRI_KEY=$(echo "$KEYS_OUT" | grep -oE '[A-Za-z0-9/=+_-]{42,45}' | sed -n '1p' | tr -d '[:space:]')
# 第二串 Base64 字符是公钥
PUB_KEY=$(echo "$KEYS_OUT" | grep -oE '[A-Za-z0-9/=+_-]{42,45}' | sed -n '2p' | tr -d '[:space:]')

# --- 调试打印 (你会看到它们不再相同) ---
echo "--- KEYS CHECK ---"
echo "Private: $PRI_KEY"
echo "Public:  $PUB_KEY"
echo "------------------"

# 3. 基础参数
LISTEN_PORT=$(shuf -i 10000-60000 -n 1)
SHORT_ID=$(openssl rand -hex 4)
SERVER_IP=$(curl -s https://api.ipify.org)
DEST="www.microsoft.com:443"
SNI="www.microsoft.com"

# 4. 生成 Xray 配置文件 (使用 PRI_KEY)
cat > /usr/local/etc/xray/config.json <<EOF
{
  "inbounds": [{
    "listen": "0.0.0.0",
    "port": $LISTEN_PORT,
    "protocol": "vless",
    "settings": {
      "clients": [{"id": "$UUID", "flow": "xtls-rprx-vision"}],
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
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF

systemctl restart xray
systemctl enable xray

# 5. 生成 Clash YAML (使用 PUB_KEY，确保单行输出)
# 使用 printf 确保不会产生意外的换行
printf -- "- {name: Linode-Reality, server: %s, port: %s, type: vless, uuid: %s, tls: true, udp: true, flow: xtls-rprx-vision, reality-opts: {public-key: %s, short-id: %s}, servername: %s, client-fingerprint: chrome, network: tcp}\n" \
"$SERVER_IP" "$LISTEN_PORT" "$UUID" "$PUB_KEY" "$SHORT_ID" "$SNI" > /root/clash_config.txt

# 6. 生成标准链接
VLESS_LINK="vless://$UUID@$SERVER_IP:$LISTEN_PORT?encryption=none&flow=xtls-rprx-vision&security=reality&sni=$SNI&fp=chrome&pbk=$PUB_KEY&sid=$SHORT_ID&type=tcp&headerType=none#Linode-Reality"
echo "$VLESS_LINK" > /root/vless_link.txt
