#!/bin/sh
# logread | grep self_control_daemon
# ================= 参数设置区 =================
# 设定【永远允许上网】的白名单 MAC 位址
ALWAYS_ONLINE_MACS="11:22:33:44:55:66 AA:BB:CC:DD:EE:FF"

# 设定允许自由上网的开始时间 (24小时制) - 解除封锁
ON_HOUR=4
ON_MIN=0

# 设定开始【自我断网约束】的时间 (24小时制) - 启动封锁
OFF_HOUR=19
OFF_MIN=0

# 每次检查的时间间隔（秒）
INTERVAL=60

# --- 新增：每日限时设备区 ---
# 设定需要被限制每天只能上 1 小时网的 MAC 地址 
QUOTA_MAC="AA:BB:CC:DD:EE:AA"
# 设定每日配额时间（分钟）
QUOTA_LIMIT_MIN=60
QUOTA_LIMIT_SEC=$((QUOTA_LIMIT_MIN * 60))

# 存储累积时间和日期的临时文件（存放在 /root 内存中，防止重启后清零）
QUOTA_FILE="/root/mac_quota_usage.txt"
QUOTA_DATE_FILE="/root/mac_quota_date.txt"

# --- 新增：特定时间段封锁设置 ---
# 设定禁止 QUOTA_MAC 上网的开始时间
WINDOW_START_H=12
WINDOW_START_M=0
# 设定禁止 QUOTA_MAC 上网的结束时间
WINDOW_END_H=15
WINDOW_END_M=30
# ==============================================

sleep 80

ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))

logger -t self_control_daemon "等待系统时间同步..."

while [ "$(date +%Y)" -lt 2024 ]
do
    sleep 5
done

logger -t self_control_daemon "时间同步完成，启动自我约束及限流巡检。"

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
        
        if [ -n "$(echo "$ALWAYS_ONLINE_MACS" | tr -d ' ')" ]
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
            uci reorder firewall.allow_iot=0
        fi
    fi
    
    uci commit firewall
    /etc/init.d/firewall reload
    
    if [ "$state" = "DOWN" ]
    then
        sleep 3
        conntrack -F 2>/dev/null
    fi
}

# ================= 特定时间段断网函数 (12:00-15:30) =================
check_time_window_block() {
    local cur_h=$(date +%H | awk '{print int($0)}')
    local cur_m=$(date +%M | awk '{print int($0)}')
    local cur_val=$((cur_h * 60 + cur_m))
    
    local start_val=$((WINDOW_START_H * 60 + WINDOW_START_M))
    local end_val=$((WINDOW_END_H * 60 + WINDOW_END_M))
    
    local in_window=0
    if [ "$start_val" -lt "$end_val" ]
    then
        if [ "$cur_val" -ge "$start_val" ] && [ "$cur_val" -lt "$end_val" ]
        then
            in_window=1
        fi
    else
        if [ "$cur_val" -ge "$start_val" ] || [ "$cur_val" -lt "$end_val" ]
        then
            in_window=1
        fi
    fi

    local rule_exists=$(uci -q get firewall.block_window)

    if [ "$in_window" -eq 1 ]
    then
        if [ -z "$rule_exists" ]
        then
            logger -t self_control_daemon "【时段锁定】进入特定封锁区间，切断 $QUOTA_MAC 网络"
            
            uci set firewall.block_window=rule
            uci set firewall.block_window.name='Block_Window_MAC'
            uci set firewall.block_window.src='lan'
            uci set firewall.block_window.dest='wan'
            uci set firewall.block_window.target='DROP'
            uci add_list firewall.block_window.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_window=0 
            uci commit firewall
            /etc/init.d/firewall reload
            
            # 【暴力切断】遍历该MAC对应的所有IP(IPv4和IPv6)，强杀所有长连接
            ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                # 剔除IPv6可能带的 %br-lan 后缀，以免 conntrack 报错
                clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                # 杀掉以此IP为源和目的地的所有活跃状态
                conntrack -D -s "$clean_ip" >/dev/null 2>&1
                conntrack -D -d "$clean_ip" >/dev/null 2>&1
            done
        fi
    else
        if [ -n "$rule_exists" ]
        then
            logger -t self_control_daemon "【时段解锁】离开特定封锁区间，恢复 $QUOTA_MAC 网络"
            uci -q delete firewall.block_window
            uci commit firewall
            /etc/init.d/firewall reload
        fi
    fi
}

# ================= 每日限额检查函数 (针对单个 MAC) =================
check_mac_quota() {
    local current_date=$(date +%Y%m%d)
    local saved_date=$(cat "$QUOTA_DATE_FILE" 2>/dev/null)
    
    if [ "$current_date" != "$saved_date" ]
    then
        logger -t self_control_daemon "新的一天，重置 $QUOTA_MAC 的上网时间"
        echo "0" > "$QUOTA_FILE"
        echo "$current_date" > "$QUOTA_DATE_FILE"
        
        uci -q delete firewall.block_quota
        uci commit firewall
        /etc/init.d/firewall reload
    fi

    local used_time=$(cat "$QUOTA_FILE" 2>/dev/null || echo "0")
    
    if [ "$used_time" -ge "$QUOTA_LIMIT_SEC" ]
    then
        if [ -z "$(uci -q get firewall.block_quota)" ]
        then
            logger -t self_control_daemon "【限额到达】$QUOTA_MAC 今日已达 ${QUOTA_LIMIT_MIN} 分钟，立即切断其网络"
            
            uci set firewall.block_quota=rule
            uci set firewall.block_quota.name='Block_Quota_MAC'
            uci set firewall.block_quota.src='lan'
            uci set firewall.block_quota.dest='wan'
            uci set firewall.block_quota.target='DROP'
            uci add_list firewall.block_quota.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_quota=0 
            uci commit firewall
            /etc/init.d/firewall reload
            
            # 【暴力切断】遍历该MAC对应的所有IP(IPv4和IPv6)，强杀所有长连接
            ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                conntrack -D -s "$clean_ip" >/dev/null 2>&1
                conntrack -D -d "$clean_ip" >/dev/null 2>&1
            done
        fi
        return 
    else
        if [ -n "$(uci -q get firewall.block_quota)" ]
        then
            logger -t self_control_daemon "【状态恢复】$QUOTA_MAC 用时未超标，清理遗留的限额拦截规则"
            uci -q delete firewall.block_quota
            uci commit firewall
            /etc/init.d/firewall reload
        fi
    fi

    local can_access_internet=1
    if [ "$LAST_STATE" = "DOWN" ]
    then
        local is_whitelisted=$(echo "$ALWAYS_ONLINE_MACS" | grep -i "$QUOTA_MAC")
        if [ -z "$is_whitelisted" ]
        then
            can_access_internet=0
        fi
    fi
    
    # === 新增防冤枉逻辑：如果该设备此时正处于12:00-15:30时段锁定中，上不了网，则不计扣额度
    if [ -n "$(uci -q get firewall.block_window)" ]
    then
        can_access_internet=0
    fi

    if [ "$can_access_internet" -eq 1 ]
    then
        ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1, $3}' | while read -r ip_addr dev_name; do
            if echo "$ip_addr" | grep -q ":"; then
                ping -c 1 -W 1 "${ip_addr}%${dev_name}" >/dev/null 2>&1
            else
                ping -c 1 -W 1 "$ip_addr" >/dev/null 2>&1
            fi
        done
        
        local is_online=$(ip neigh show | grep -i "$QUOTA_MAC" | egrep -i "REACHABLE|DELAY")

        if [ -n "$is_online" ]
        then
            used_time=$((used_time + INTERVAL))
            echo "$used_time" > "$QUOTA_FILE"
            # 若要验证它是否在计时，可以把下面这行日志的注释取消掉：
            # logger -t self_control_daemon "设备 $QUOTA_MAC 正在上网，今日累计已用: $((used_time / 60)) 分钟"
        fi
    fi
}
# ==================================================

LAST_STATE="UNKNOWN"

while true
do
    CUR_H=$(date +%H | awk '{print int($0)}')
    CUR_M=$(date +%M | awk '{print int($0)}')
    CUR_VAL=$((CUR_H * 60 + CUR_M))

    TARGET_STATE="DOWN"

    if [ "$ON_VAL" -lt "$OFF_VAL" ]
    then
        if [ "$CUR_VAL" -ge "$ON_VAL" ] && [ "$CUR_VAL" -lt "$OFF_VAL" ]
        then
            TARGET_STATE="UP"
        fi
    else
        if [ "$CUR_VAL" -ge "$ON_VAL" ] || [ "$CUR_VAL" -lt "$OFF_VAL" ]
        then
            TARGET_STATE="UP"
        fi
    fi

    if [ "$TARGET_STATE" != "$LAST_STATE" ]
    then
        if [ "$TARGET_STATE" = "UP" ]
        then
            logger -t self_control_daemon "当前时间在放行区间，解除全局网络约束"
            update_firewall_rule "UP" 
        else
            logger -t self_control_daemon "【注意】进入约束时间！已启动全局断网策略"
            update_firewall_rule "DOWN"
        fi
        LAST_STATE="$TARGET_STATE"
    fi
    
    check_time_window_block
    check_mac_quota
    
    sleep $INTERVAL
done