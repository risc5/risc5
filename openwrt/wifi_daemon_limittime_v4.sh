#!/bin/sh
# logread | grep self_control_daemon
# ================= 参数设置区 =================
# 设定【永远允许上网】的白名单 MAC 位址
ALWAYS_ONLINE_MACS="11:22:33:44:55:66 AA:BB:CC:DD:EE:FF"

# 设定允许自由上网的开始时间 (24小时制) - 解除封锁
ON_HOUR=4
ON_MIN=0

# 设定开始【自我断网约束】的时间 (24小时制) - 启动封锁
OFF_HOUR=22
OFF_MIN=0

# 每次检查的时间间隔（秒）
INTERVAL=60

# --- 新增：每日限时设备区 ---
# 设定需要被限制每天只能上 1 小时网的 MAC 地址 
QUOTA_MAC="FE:09:4A:EA:E7:E3"
# 设定每日配额时间（分钟）
QUOTA_LIMIT_MIN=60

# 存储累积时间和日期的临时文件（存放在 /root 内存中，防止重启后清零）
QUOTA_FILE="/root/mac_quota_usage.txt"
QUOTA_DATE_FILE="/root/mac_quota_date.txt"

# --- 新增：特定时间段封锁设置 ---
# 设定禁止 QUOTA_MAC 上网的开始时间
WINDOW_START_H=22
WINDOW_START_M=08
# 设定禁止 QUOTA_MAC 上网的结束时间
WINDOW_END_H=22
WINDOW_END_M=30
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
WINDOW_START_H=$(clean_num "$WINDOW_START_H")
WINDOW_START_M=$(clean_num "$WINDOW_START_M")
WINDOW_END_H=$(clean_num "$WINDOW_END_H")
WINDOW_END_M=$(clean_num "$WINDOW_END_M")
QUOTA_LIMIT_MIN=$(clean_num "$QUOTA_LIMIT_MIN")

# 预计算固定阈值
QUOTA_LIMIT_SEC=$((QUOTA_LIMIT_MIN * 60))
ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))
WINDOW_START_VAL=$((WINDOW_START_H * 60 + WINDOW_START_M))
WINDOW_END_VAL=$((WINDOW_END_H * 60 + WINDOW_END_M))
# ===================================================================

sleep 8

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
            # 将 QUOTA_MAC 加入全局白名单，使其不受全局断网影响
            uci add_list firewall.allow_iot.src_mac="$QUOTA_MAC"
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

    rule_exists=$(uci -q get firewall.block_window_fwd)
    
    if [ "$WINDOW_START_VAL" -lt "$WINDOW_END_VAL" ]
    then
        if [ "$CUR_VAL" -ge "$WINDOW_START_VAL" ] && [ "$CUR_VAL" -lt "$WINDOW_END_VAL" ]; then
            in_window=1
        fi
    else
        if [ "$CUR_VAL" -ge "$WINDOW_START_VAL" ] || [ "$CUR_VAL" -lt "$WINDOW_END_VAL" ]; then
            in_window=1
        fi
    fi

    if [ "$in_window" -eq 1 ]
    then
        if [ -z "$rule_exists" ]
        then
            logger -t self_control_daemon "【时段锁定】进入特定封锁区间，切断 $QUOTA_MAC 网络(包含代理绕过)"
            
            uci set firewall.block_window_fwd=rule
            uci set firewall.block_window_fwd.name='Block_Window_MAC_FWD'
            uci set firewall.block_window_fwd.src='lan'
            uci set firewall.block_window_fwd.dest='*'
            uci set firewall.block_window_fwd.target='DROP'
            uci add_list firewall.block_window_fwd.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_window_fwd=0 

            uci set firewall.block_window_in=rule
            uci set firewall.block_window_in.name='Block_Window_MAC_IN'
            uci set firewall.block_window_in.src='lan'
            uci set firewall.block_window_in.target='DROP'
            uci add_list firewall.block_window_in.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_window_in=0 
            
            uci commit firewall
            /etc/init.d/firewall reload >/dev/null 2>&1
            
            sleep 5
            
            for i in 1 2; do
                ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                    clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                    conntrack -D -s "$clean_ip" >/dev/null 2>&1
                    conntrack -D -d "$clean_ip" >/dev/null 2>&1
                done
                sleep 1
            done
        fi
    else
        if [ -n "$rule_exists" ]
        then
            logger -t self_control_daemon "【时段解锁/状态恢复】离开封锁区间，清理遗留规则并恢复 $QUOTA_MAC 网络"
            uci -q delete firewall.block_window_fwd
            uci -q delete firewall.block_window_in
            uci commit firewall
            /etc/init.d/firewall reload >/dev/null 2>&1
            
            sleep 4
            
            ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                conntrack -D -s "$clean_ip" >/dev/null 2>&1
                conntrack -D -d "$clean_ip" >/dev/null 2>&1
            done
        fi
    fi
}

# ================= 每日限额检查函数 =================
check_mac_quota() {
    local current_date
    local saved_date
    local used_time

    current_date=$(date +%Y%m%d)
    saved_date=$(cat "$QUOTA_DATE_FILE" 2>/dev/null)
    
    if [ "$current_date" != "$saved_date" ]
    then
        logger -t self_control_daemon "新的一天，重置 $QUOTA_MAC 的上网时间"
        echo "0" > "$QUOTA_FILE"
        echo "$current_date" > "$QUOTA_DATE_FILE"
        
        uci -q delete firewall.block_quota_fwd
        uci -q delete firewall.block_quota_in
        uci commit firewall
        /etc/init.d/firewall reload >/dev/null 2>&1
    fi

    used_time=$(cat "$QUOTA_FILE" 2>/dev/null)
    used_time=$(clean_num "$used_time")
    
    if [ "$used_time" -ge "$QUOTA_LIMIT_SEC" ]
    then
        if [ -z "$(uci -q get firewall.block_quota_fwd)" ]
        then
            logger -t self_control_daemon "【限额到达】$QUOTA_MAC 今日已达 ${QUOTA_LIMIT_MIN} 分钟，彻底切断网络"
            
            uci set firewall.block_quota_fwd=rule
            uci set firewall.block_quota_fwd.name='Block_Quota_MAC_FWD'
            uci set firewall.block_quota_fwd.src='lan'
            uci set firewall.block_quota_fwd.dest='*'
            uci set firewall.block_quota_fwd.target='DROP'
            uci add_list firewall.block_quota_fwd.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_quota_fwd=0 

            uci set firewall.block_quota_in=rule
            uci set firewall.block_quota_in.name='Block_Quota_MAC_IN'
            uci set firewall.block_quota_in.src='lan'
            uci set firewall.block_quota_in.target='DROP'
            uci add_list firewall.block_quota_in.src_mac="$QUOTA_MAC"
            uci reorder firewall.block_quota_in=0 
            
            uci commit firewall
            /etc/init.d/firewall reload >/dev/null 2>&1
            
            sleep 5
            
            for i in 1 2; do
                ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                    clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                    conntrack -D -s "$clean_ip" >/dev/null 2>&1
                    conntrack -D -d "$clean_ip" >/dev/null 2>&1
                done
                sleep 1
            done
        fi
        return 
    else
        if [ -n "$(uci -q get firewall.block_quota_fwd)" ]
        then
            logger -t self_control_daemon "【状态恢复】$QUOTA_MAC 用时未超标，清理遗留的限额拦截规则"
            uci -q delete firewall.block_quota_fwd
            uci -q delete firewall.block_quota_in
            uci commit firewall
            /etc/init.d/firewall reload >/dev/null 2>&1
            
            sleep 4
            
            ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | while read -r ip_addr; do
                clean_ip=$(echo "$ip_addr" | awk -F'%' '{print $1}')
                conntrack -D -s "$clean_ip" >/dev/null 2>&1
                conntrack -D -d "$clean_ip" >/dev/null 2>&1
            done
        fi
    fi

    local can_access_internet=1
    # QUOTA_MAC 已加入全局白名单，此处不再受全局断网状态的影响
    
    if [ -n "$(uci -q get firewall.block_window_fwd)" ]; then
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
        
        local is_online
        is_online=$(ip neigh show | grep -i "$QUOTA_MAC" | egrep -i "REACHABLE|DELAY")

        if [ -n "$is_online" ]; then
            used_time=$((used_time + INTERVAL))
            echo "$used_time" > "$QUOTA_FILE"
        fi
    fi
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
            logger -t self_control_daemon "【注意】进入约束时间！已启动全局断网策略 不包括$QUOTA_MAC "
            update_firewall_rule "DOWN"
        fi
        LAST_STATE="$TARGET_STATE"
    fi
    
    check_time_window_block
    check_mac_quota
    
    sleep $INTERVAL
done