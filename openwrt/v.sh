#!/bin/sh

# 文件路径
IP_FILE="/root/blocked_videoqq_ip.txt"

# 要屏蔽的网站列表
SITES="video.qq.com v.qq.com tool.liumingye.cn"

# 确保 IP 文件存在
touch $IP_FILE

# 获取当前 IP 并保存，返回 changed=1 表示有更新
get_ips() {
    changed=0
    echo "[$(date)] 开始获取网站 IP..."
    logger -t block_videoqq "开始获取网站 IP"

    for site in $SITES; do
        ip=$(ping -c 1 -W 1 $site 2>/dev/null | head -1 | grep -oE '([0-9]{1,3}\.){3}[0-9]{1,3}')
        if [ -n "$ip" ]; then
            echo "[$(date)] 获取到 $site 的 IP: $ip"
            logger -t block_videoqq "获取到 $site 的 IP: $ip"

            if grep -q "^$site " $IP_FILE 2>/dev/null; then
                old_ip=$(grep "^$site " $IP_FILE | awk '{print $2}')
                if [ "$old_ip" != "$ip" ]; then
                    sed -i "s/^$site .*/$site $ip/" $IP_FILE
                    echo "[$(date)] $site IP 已更新: $old_ip -> $ip"
                    logger -t block_videoqq "$site IP 已更新: $old_ip -> $ip"
                    changed=1
                fi
            else
                echo "$site $ip" >> $IP_FILE
                echo "[$(date)] $site IP 写入文件: $ip"
                logger -t block_videoqq "$site IP 写入文件: $ip"
                changed=1
            fi
        else
            echo "[$(date)] 获取 $site IP 失败"
            logger -t block_videoqq "获取 $site IP 失败"
        fi
    done
}

# 更新防火墙规则，只修改已有规则 dest_ip 或新增一次
update_firewall_rules() {
    echo "[$(date)] 开始更新防火墙规则..."
    logger -t block_videoqq "开始更新防火墙规则"

    for site in $SITES; do
        safe_name=$(echo "$site" | tr '.' '_')
        ip_var=$(grep "^$site " $IP_FILE | awk '{print $2}')
        # 查找所有已有规则，确保只有一个
        rule_ids=$(uci show firewall | grep "block_${safe_name}" | cut -d'.' -f2 | cut -d'=' -f1)

        if [ -n "$ip_var" ]; then
            if [ -n "$rule_ids" ]; then
                # 只保留第一个规则，删除重复规则
                first_rule=$(echo "$rule_ids" | awk '{print $1}')
                for rid in $rule_ids; do
                    if [ "$rid" != "$first_rule" ]; then
                        uci delete firewall.$rid
                        echo "[$(date)] 删除重复规则: $rid"
                        logger -t block_videoqq "删除重复规则: $rid"
                    fi
                done
                # 更新第一个规则的 dest_ip
                uci set firewall.$first_rule.dest_ip="$ip_var"
                echo "[$(date)] 更新规则: $site -> $ip_var"
                logger -t block_videoqq "更新规则: $site -> $ip_var"
            else
                # 没有规则则新增一次
                uci add firewall rule
                uci set firewall.@rule[-1].name="block_${safe_name}"
                uci set firewall.@rule[-1].src="lan"
                uci set firewall.@rule[-1].dest='wan'
                uci set firewall.@rule[-1].dest_ip="$ip_var"
                uci set firewall.@rule[-1].proto="all"
                uci set firewall.@rule[-1].target="REJECT"
                echo "[$(date)] 新增规则: $site -> $ip_var"
                logger -t block_videoqq "新增规则: $site -> $ip_var"
            fi
        else
            echo "[$(date)] $site IP 不存在，跳过规则更新"
            logger -t block_videoqq "$site IP 不存在，跳过规则更新"
        fi
    done

    uci commit firewall
    /etc/init.d/firewall restart
    echo "[$(date)] 防火墙规则已更新并重启"
    logger -t block_videoqq "防火墙规则已更新并重启"
}

# ---- 初始化运行 ----
changed=0
get_ips
update_firewall_rules

# ---- 循环定时，每60分钟检查一次 ----
while true; do
    changed=0
    get_ips
    if [ $changed -eq 1 ]; then
        update_firewall_rules
    fi
    # 调试使用 sleep 10，正式环境使用 3600
    sleep 10
done
