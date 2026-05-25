#!/bin/sh
# logread | grep self_control_daemon
# ================= 参数设置区 =================
# 设定【永远允许上网】的白名单 MAC 位址
ALWAYS_ONLINE_MACS="11:22:33:44:55:66 AA:BB:CC:DD:EE:FF"

# 设定允许自由上网的开始时间 (24小时制) - 解除封锁
ON_HOUR=4
ON_MIN=0

# 设定开始【自我断网约束】的时间 (24小时制) - 启动封锁
OFF_HOUR=17
OFF_MIN=0

# 每次检查的时间间隔（秒）
INTERVAL=60

# --- 新增：每日限时设备区 ---
# 设定需要被限制每天只能上 1 小时网的 MAC 地址 (支持空格分隔配置多个 MAC 地址)
QUOTA_MAC="AA:BB:CC:DD:EE:BB AA:BB:CC:DD:EE:CC"
# 设定每日配额时间（分钟）
QUOTA_LIMIT_MIN=60

# 存储累积时间和日期的临时文件（存放在 /root 内存中，防止重启后清零）
QUOTA_FILE="/root/mac_quota_usage.txt"
QUOTA_DATE_FILE="/root/mac_quota_date.txt"

# --- 新增：特定时间段封锁设置 (支持多时间段) ---
# 设定禁止 QUOTA_MAC 上网的时间段列表 (格式: 开始时:开始分-结束时:结束分)
# 可以用空格分隔随意增加多个时间段，若跨天(如22:30到4:00)，系统会自动判断。
BLOCK_WINDOWS="12:03-15:03 22:30-04:00"
# ==============================================

# ================= 核心修复：数字净化与八进制防护 (BusyBox 兼容版) =================
clean_num() {
    # 使用 awk 进行万能的、兼容性最强的数字转换，彻底杜绝八进制和空值问题
    local num_in="$1"
    if [ -z "$num_in" ]; then
        num_in=0
    fi
    echo "$num_in" | awk '{print $1 + 0}'
}

# 初始化参数：过滤并转换为纯数字
ON_HOUR=$(clean_num "$ON_HOUR")
ON_MIN=$(clean_num "$ON_MIN")
OFF_HOUR=$(clean_num "$OFF_HOUR")
OFF_MIN=$(clean_num "$OFF_MIN")
QUOTA_LIMIT_MIN=$(clean_num "$QUOTA_LIMIT_MIN")

# 预计算固定阈值
QUOTA_LIMIT_SEC=$((QUOTA_LIMIT_MIN * 60))
ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))
# ===================================================================

sleep 80

logger -t self_control_daemon "等待系统时间同步..."

while [ "$(date +%Y)" -lt 2024 ]
do
    sleep 5
done

logger -t self_control_daemon "时间同步完成，启动自我约束及限流巡检。"


# ================= 物理切断 Wi-Fi 函数 =================
# 该函数会扫描所有无线接口 (2.4G, 5G, 访客网络等) 并强制踢出目标 MAC
kick_mac_from_wifi() {
    local target_mac=$1
    logger -t self_control_daemon "执行物理切断：强制剔除 $target_mac 的 Wi-Fi 连接"
    
    # 自动获取当前所有活跃的无线 hostapd 接口 (如 hostapd.wlan0, hostapd.wlan1)
    local interfaces=$(ubus list hostapd.* | awk -F'hostapd.' '{print $2}')
    
    for iface in $interfaces; do
        # 发送 Deauth 指令，并封禁 60 秒 (配合脚本循环)
        ubus call hostapd.$iface del_client "{ \"addr\": \"$target_mac\", \"reason\": 1, \"deauth\": true, \"ban_time\": 60000 }" >/dev/null 2>&1
    done
}

# ================= 防火墙控制函数 (全局控制) =================
update_firewall_rule() {
    local state=$1
    
    uci -q delete firewall.allow_iot
    uci -q delete firewall.block_self
    
    if [ "$state" = "DOWN" ]
    then
        uci set firewall.block_self=rule
        uci set firewall.block_self.name='Block_Self_And_Random_MACs'
        uci set firewall.block_self.src='lan'
        uci set firewall.block_self.dest='wan'
        uci set firewall.block_self.target='REJECT'
        uci reorder firewall.block_self=0
        
        if [ -n "$(echo "$ALWAYS_ONLINE_MACS" | tr -d ' ')" ] || [ -n "$(echo "$QUOTA_MAC" | tr -d ' ')" ]
        then
            uci set firewall.allow_iot=rule
            uci set firewall.allow_iot.name='Allow_IoT_And_Servers'
            uci set firewall.allow_iot.src='lan'
            uci set firewall.allow_iot.dest='wan'
            uci set firewall.allow_iot.target='ACCEPT'
            
            for mac in $ALWAYS_ONLINE_MACS
            do
                uci add_list firewall.allow_iot.src_mac="$mac"
            done
            # 将 QUOTA_MAC 组内所有设备加入全局白名单，使其不受全局断网影响
            for mac in $QUOTA_MAC
            do
                uci add_list firewall.allow_iot.src_mac="$mac"
            done
            uci reorder firewall.allow_iot=0
        fi
    fi
    
    uci commit firewall
    /etc/init.d/firewall reload >/dev/null 2>&1
    
    if [ "$state" = "DOWN" ]
    then
        sleep 3
        conntrack -F 2>/dev/null
    fi
}

# ================= 特定时间段断网函数 =================
check_time_window_block() {
    local rule_exists
    local in_window=0
    local window start_time end_time start_h start_m end_h end_m start_val end_val
    local mac

    # 遍历检查当前时间是否命中配置的任何一个时间段
    for window in $BLOCK_WINDOWS; do
        start_time=$(echo "$window" | cut -d'-' -f1)
        end_time=$(echo "$window" | cut -d'-' -f2)

        start_h=$(clean_num "$(echo "$start_time" | cut -d':' -f1)")
        start_m=$(clean_num "$(echo "$start_time" | cut -d':' -f2)")
        end_h=$(clean_num "$(echo "$end_time" | cut -d':' -f2)")
        end_m=$(clean_num "$(echo "$end_time" | cut -d':' -f2)")

        start_val=$((start_h * 60 + start_m))
        end_val=$((end_h * 60 + end_m))

        if [ "$start_val" -lt "$end_val" ]
        then
            if [ "$CUR_VAL" -ge "$start_val" ] && [ "$CUR_VAL" -lt "$end_val" ]; then
                in_window=1
                break
            fi
        else
            # 跨天的时间段处理 (例如 22:30 到 04:00)
            if [ "$CUR_VAL" -ge "$start_val" ] || [ "$CUR_VAL" -lt "$end_val" ]; then
                in_window=1
                break
            fi
        fi
    done

    # 分别针对组内的每一个 MAC 地址单独操作防火墙规则
    for mac in $QUOTA_MAC; do
        # 根据 MAC 地址生成唯一的防火墙规则配置名后缀（将冒号替换为下划线，以符合 uci 命名规范）
        local safe_mac=$(echo "$mac" | tr ':' '_')
        rule_exists=$(uci -q get firewall.blk_win_fwd_${safe_mac})

        if [ "$in_window" -eq 1 ]
        then
            if [ -z "$rule_exists" ]
            then
                logger -t self_control_daemon "【时段锁定】进入特定封锁区间，切断 $mac 网络(包含代理绕过)"
                
                uci set firewall.blk_win_fwd_${safe_mac}=rule
                uci set firewall.blk_win_fwd_${safe_mac}.name="Blk_Win_MAC_FWD_${safe_mac}"
                uci set firewall.blk_win_fwd_${safe_mac}.src='lan'
                uci set firewall.blk_win_fwd_${safe_mac}.dest='*'
                uci set firewall.blk_win_fwd_${safe_mac}.target='DROP'
                uci add_list firewall.blk_win_fwd_${safe_mac}.src_mac="$mac"
                uci reorder firewall.blk_win_fwd_${safe_mac}=0 

                uci set firewall.blk_win_in_${safe_mac}=rule
                uci set firewall.blk_win_in_${safe_mac}.name="Blk_Win_MAC_IN_${safe_mac}"
                uci set firewall.blk_win_in_${safe_mac}.src='lan'
                uci set firewall.blk_win_in_${safe_mac}.target='DROP'
                uci add_list firewall.blk_win_in_${safe_mac}.src_mac="$mac"
                uci reorder firewall.blk_win_in_${safe_mac}=0 
                
                uci commit firewall
                /etc/init.d/firewall reload >/dev/null 2>&1
                
                sleep 5
                
                for i in $(seq 1 10); do
                    ip neigh show | grep -i "$mac" | awk '{print $1}' | while read -r ip_addr; do
                        clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                        conntrack -D -s "$clean_ip" >/dev/null 2>&1
                        conntrack -D -d "$clean_ip" >/dev/null 2>&1
                    done
                    sleep 1
                done
                kick_mac_from_wifi "$mac"
            fi
        else
            if [ -n "$rule_exists" ]
            then
                logger -t self_control_daemon "【时段解锁/状态恢复】离开封锁区间，清理遗留规则并恢复 $mac 网络"
                uci -q delete firewall.blk_win_fwd_${safe_mac}
                uci -q delete firewall.blk_win_in_${safe_mac}
                uci commit firewall
                /etc/init.d/firewall reload >/dev/null 2>&1
                
                sleep 4
                
                ip neigh show | grep -i "$mac" | awk '{print $1}' | while read -r ip_addr; do
                    clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                    conntrack -D -s "$clean_ip" >/dev/null 2>&1
                    conntrack -D -d "$clean_ip" >/dev/null 2>&1
                done
            fi
        fi
    done
}

# ================= 每日限额检查函数 =================
check_mac_quota() {
    local current_date
    local saved_date
    local mac

    current_date=$(date +%Y%m%d)
    saved_date=$(cat "$QUOTA_DATE_FILE" 2>/dev/null)
    
    if [ "$current_date" != "$saved_date" ]
    then
        logger -t self_control_daemon "新的一天，重置所有限额设备的上网时间"
        rm -f "$QUOTA_FILE"
        echo "$current_date" > "$QUOTA_DATE_FILE"
        
        # 清理旧的所有限额防火墙规则
        for mac in $QUOTA_MAC; do
            local safe_mac=$(echo "$mac" | tr ':' '_')
            uci -q delete firewall.blk_qta_fwd_${safe_mac}
            uci -q delete firewall.blk_qta_in_${safe_mac}
        done
        uci commit firewall
        /etc/init.d/firewall reload >/dev/null 2>&1
    fi

    # 循环对每个 MAC 独立判断计时与阻断逻辑
    for mac in $QUOTA_MAC; do
        local safe_mac=$(echo "$mac" | tr ':' '_')
        local used_time
        
        # 从限额文件中提取当前 MAC 的累积时间
        used_time=$(grep -i "^${mac} " "$QUOTA_FILE" 2>/dev/null | awk '{print $2}')
        used_time=$(clean_num "$used_time")
        
        if [ "$used_time" -ge "$QUOTA_LIMIT_SEC" ]
        then
            if [ -z "$(uci -q get firewall.blk_qta_fwd_${safe_mac})" ]
            then
                logger -t self_control_daemon "【限额到达】$mac 今日已达 ${QUOTA_LIMIT_MIN} 分钟，彻底切断网络"
                
                uci set firewall.blk_qta_fwd_${safe_mac}=rule
                uci set firewall.blk_qta_fwd_${safe_mac}.name="Blk_Qta_MAC_FWD_${safe_mac}"
                uci set firewall.blk_qta_fwd_${safe_mac}.src='lan'
                uci set firewall.blk_qta_fwd_${safe_mac}.dest='*'
                uci set firewall.blk_qta_fwd_${safe_mac}.target='DROP'
                uci add_list firewall.blk_qta_fwd_${safe_mac}.src_mac="$mac"
                uci reorder firewall.blk_qta_fwd_${safe_mac}=0 

                uci set firewall.blk_qta_in_${safe_mac}=rule
                uci set firewall.blk_qta_in_${safe_mac}.name="Blk_Qta_MAC_IN_${safe_mac}"
                uci set firewall.blk_qta_in_${safe_mac}.src='lan'
                uci set firewall.blk_qta_in_${safe_mac}.target='DROP'
                uci add_list firewall.blk_qta_in_${safe_mac}.src_mac="$mac"
                uci reorder firewall.blk_qta_in_${safe_mac}=0 
                
                uci commit firewall
                /etc/init.d/firewall reload >/dev/null 2>&1
                
                sleep 5
                
                for i in $(seq 1 10); do
                    ip neigh show | grep -i "$mac" | awk '{print $1}' | while read -r ip_addr; do
                        clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                        conntrack -D -s "$clean_ip" >/dev/null 2>&1
                        conntrack -D -d "$clean_ip" >/dev/null 2>&1
                    done
                    sleep 1
                done
                kick_mac_from_wifi "$mac"
            fi
            continue
        else
            if [ -n "$(uci -q get firewall.blk_qta_fwd_${safe_mac})" ]
            then
                logger -t self_control_daemon "【状态恢复】$mac 用时未超标，清理遗留的限额拦截规则"
                uci -q delete firewall.blk_qta_fwd_${safe_mac}
                uci -q delete firewall.blk_qta_in_${safe_mac}
                uci commit firewall
                /etc/init.d/firewall reload >/dev/null 2>&1
                
                sleep 4
                
                ip neigh show | grep -i "$mac" | awk '{print $1}' | while read -r ip_addr; do
                    clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                    conntrack -D -s "$clean_ip" >/dev/null 2>&1
                    conntrack -D -d "$clean_ip" >/dev/null 2>&1
                done
            fi
        fi

        local can_access_internet=1
        # QUOTA_MAC 已加入全局白名单，此处不再受全局断网状态的影响
        
        if [ -n "$(uci -q get firewall.blk_win_fwd_${safe_mac})" ]; then
            can_access_internet=0
        fi

        if [ "$can_access_internet" -eq 1 ]
        then
            ip neigh show | grep -i "$mac" | awk '{print $1, $3}' | while read -r ip_addr dev_name; do
                if echo "$ip_addr" | grep -q ":"; then
                    ping -c 1 -W 1 "${ip_addr}%${dev_name}" >/dev/null 2>&1
                else
                    ping -c 1 -W 1 "$ip_addr" >/dev/null 2>&1
                fi
            done
            
            local is_online
            is_online=$(ip neigh show | grep -i "$mac" | egrep -i "REACHABLE|DELAY")

            if [ -n "$is_online" ]; then
                used_time=$((used_time + INTERVAL))
                
                # 安全更新独立设备的配额时间文件记录
                if [ -f "$QUOTA_FILE" ] && grep -q -i "^${mac} " "$QUOTA_FILE"; then
                    sed -i "s/^${mac} .*/${mac} ${used_time}/gI" "$QUOTA_FILE"
                else
                    echo "${mac} ${used_time}" >> "$QUOTA_FILE"
                fi
            fi
        fi
    done
}
# ==================================================

LAST_STATE="UNKNOWN"

while true
do
    CUR_H=$(clean_num "$(date +%H)")
    CUR_M=$(clean_num "$(date +%M)")
    CUR_VAL=$((CUR_H * 60 + CUR_M))

    TARGET_STATE="DOWN"

    if [ "$ON_VAL" -lt "$OFF_VAL" ]
    then
        if [ "$CUR_VAL" -ge "$ON_VAL" ] && [ "$CUR_VAL" -lt "$OFF_VAL" ]; then
            TARGET_STATE="UP"
        fi
    else
        if [ "$CUR_VAL" -ge "$ON_VAL" ] || [ "$CUR_VAL" -lt "$OFF_VAL" ]; then
            TARGET_STATE="UP"
        fi
    fi

    if [ "$TARGET_STATE" != "$LAST_STATE" ]
    then
        if [ "$TARGET_STATE" = "UP" ]; then
            logger -t self_control_daemon "当前时间在放行区间，解除全局网络约束"
            update_firewall_rule "UP" 
        else
            logger -t self_control_daemon "【注意】进入约束时间！已启动全局断网策略 不包括 $QUOTA_MAC"
            update_firewall_rule "DOWN"
        fi
        LAST_STATE="$TARGET_STATE"
    fi
    
    check_time_window_block
    check_mac_quota
    
    sleep $INTERVAL
done