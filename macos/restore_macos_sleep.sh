#!/usr/bin/env bash
# restore_defaults.sh - 恢复出厂默认电源参数

if [ "$EUID" -ne 0 ]; then
    echo "错误：请使用 sudo 运行此脚本: sudo bash $0"
    exit 1
fi

# 1. 恢复混合睡眠模式（RAM 供电维持）
pmset -a hibernatemode 3

# 2. 恢复高低电量下的标准待机延迟时间
pmset -a standbydelayhigh 86400
pmset -a standbydelaylow 10800

# 3. 恢复开盖自动亮屏唤醒
pmset -a lidwake 1

pmset -a tcpkeepalive 1
# 读取并显示当前设置值
echo ">>> 默认参数已恢复，当前参数值："
pmset -g | grep -E "hibernatemode|lidwake|standbydelay|tcpkeepalive"
