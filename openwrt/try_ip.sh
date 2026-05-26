#!/bin/sh

# 要屏蔽的 IP 地址列表 (用空格分隔)
TARGET_IPS="17.57.145.135 17.57.145.150 120.204.0.25 221.181.99.18"

update_firewall_rules() {
    echo "[$(date)] 开始检查并更新防火墙拦截规则..."
    logger -t block_ips "开始检查并更新防火墙规则"

    local changed=0

    for ip in $TARGET_IPS; do
        # 将 IP 里的点替换为下划线，用于规则命名 (例如: block_ip_17_57_145_135)
        safe_name=$(echo "$ip" | tr '.' '_')
        rule_name="block_ip_${safe_name}"

        # 查找当前是否已经存在该 IP 的规则 ID (兼容 uci 输出带或不带引号的情况)
        rule_ids=$(uci show firewall | grep -E "name='?${rule_name}'?" | cut -d'.' -f2 | cut -d'=' -f1 | sort | uniq)

        if [ -n "$rule_ids" ]; then
            # 如果存在规则，确保只保留第一个，删除可能存在的重复规则
            first_rule=$(echo "$rule_ids" | awk 'NR==1{print $1}')
            for rid in $rule_ids; do
                if [ "$rid" != "$first_rule" ]; then
                    uci delete firewall."$rid"
                    echo "[$(date)] 删除重复规则: $rid (针对 $ip)"
                    logger -t block_ips "删除重复规则: $rid (针对 $ip)"
                    changed=1
                fi
            done
            echo "[$(date)] 规则已存在: 拦截 $ip (规则名: $rule_name)"
        else
            # 没有该 IP 的规则，执行新增
            uci add firewall rule >/dev/null
            uci set firewall.@rule[-1].name="${rule_name}"
            uci set firewall.@rule[-1].src="lan"
            uci set firewall.@rule[-1].dest="wan"
            uci set firewall.@rule[-1].dest_ip="$ip"
            uci set firewall.@rule[-1].proto="all"
            uci set firewall.@rule[-1].target="REJECT"
            
            echo "[$(date)] 新增拦截规则: $ip"
            logger -t block_ips "新增拦截规则: $ip"
            changed=1
        fi
    done

    # 只有在发生新增或删除操作时，才提交并重启防火墙
    if [ "$changed" -eq 1 ]; then
        uci commit firewall
        /etc/init.d/firewall restart
        echo "[$(date)] 防火墙规则已更新并重启生效。"
        logger -t block_ips "防火墙规则已更新并重启生效"
    else
        echo "[$(date)] 所有拦截规则均已在位，防火墙状态保持不变。"
        logger -t block_ips "规则均已存在，无需更新"
    fi
}

# ---- 执行 ----
update_firewall_rules
