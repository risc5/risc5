#!/usr/bin/env bash
# fix_sleep.sh - 解决合盖误触高负载与伪唤醒

if [ "$EUID" -ne 0 ]; then
    echo "错误：请使用 sudo 运行此脚本: sudo bash $0"
    exit 1
fi

# 1. 强制启用磁盘休眠（切断键盘/触控板供电，杜绝挤压误触）
pmset -a hibernatemode 25

# 2. 待机延迟设为 0 秒，合盖立刻落盘断电
pmset -a standbydelayhigh 0
pmset -a standbydelaylow 0

# 3. 关闭开盖自动唤醒（防止包内转轴微动亮屏）
pmset -a lidwake 0
pmset -a tcpkeepalive 0

# 读取并显示当前设置值
echo ">>> 配置已应用，当前参数值："
pmset -g | grep -E "hibernatemode|lidwake|standbydelay|tcpkeepalive"
