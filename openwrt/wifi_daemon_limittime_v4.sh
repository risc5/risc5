#!/bin/sh

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
INTERVAL=300

# --- 新增：每日限时设备区 ---
# 设定需要被限制每天只能上 1 小时网的 MAC 地址 
QUOTA_MAC="AA:BB:CC:DD:EE:GG"
# 设定每日配额时间（分钟）
QUOTA_LIMIT_MIN=60
QUOTA_LIMIT_SEC=$((QUOTA_LIMIT_MIN * 60))

# 存储累积时间和日期的临时文件（存放在 /tmp 内存中，重启后清零）
QUOTA_FILE="/etc/mac_quota_usage.txt"
QUOTA_DATE_FILE="/etc/mac_quota_date.txt"
# ==============================================

sleep 80

ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))

logger -t self_control_daemon "等待系统时间同步..."

# [针对 BusyBox 优化]：将 do 换行，彻底避免解析错误
while [ "$(date +%Y)" -lt 2024 ]
do
    sleep 5
done

logger -t self_control_daemon "时间同步完成，启动自我约束及限流巡检。"

# ================= 防火墙控制函数 (全局控制) =================
update_firewall_rule() {
    local state=$1
    
    # 清理旧的全局规则
    uci -q delete firewall.allow_iot
    uci -q delete firewall.block_self
    
    if [ "$state" = "DOWN" ]
    then
        # 创建拦截规则
        uci set firewall.block_self=rule
        uci set firewall.block_self.name='Block_Self_And_Random_MACs'
        uci set firewall.block_self.src='lan'
        uci set firewall.block_self.dest='wan'
        uci set firewall.block_self.target='REJECT'
        uci reorder firewall.block_self=0
        
        # 处理白名单
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

# ================= 每日限额检查函数 (针对单个 MAC) =================
check_mac_quota() {
    local current_date=$(date +%Y%m%d)
    local saved_date=$(cat "$QUOTA_DATE_FILE" 2>/dev/null)
    
    # 1. 判断是否跨天，如果是则重置
    if [ "$current_date" != "$saved_date" ]
    then
        logger -t self_control_daemon "新的一天，重置 $QUOTA_MAC 的上网时间"
        echo "0" > "$QUOTA_FILE"
        echo "$current_date" > "$QUOTA_DATE_FILE"
        
        # 移除限额阻断规则
        uci -q delete firewall.block_quota
        uci commit firewall
        /etc/init.d/firewall reload
    fi

    # 2. 读取当前已用时长（秒）
    local used_time=$(cat "$QUOTA_FILE" 2>/dev/null || echo "0")
    
    # 3. 检查是否达到限额
    if [ "$used_time" -ge "$QUOTA_LIMIT_SEC" ]
    then
        # 如果达到了，并且尚未建立阻断规则，则建立规则
        if [ -z "$(uci -q get firewall.block_quota)" ]
        then
            logger -t self_control_daemon "【限额到达】$QUOTA_MAC 今日已达 ${QUOTA_LIMIT_MIN} 分钟，立即切断其网络"
            
            uci set firewall.block_quota=rule
            uci set firewall.block_quota.name='Block_Quota_MAC'
            uci set firewall.block_quota.src='lan'
            uci set firewall.block_quota.dest='wan'
            uci set firewall.block_quota.target='REJECT'
            uci add_list firewall.block_quota.src_mac="$QUOTA_MAC"
            # 将限流阻断置于最顶层，使其优先级高于一切（包括全局白名单放行）
            uci reorder firewall.block_quota=0 
            uci commit firewall
            /etc/init.d/firewall reload
            
            # 清理该设备的连接状态以实现“秒断”
            local mac_ip=$(ip neigh show | grep -i "$QUOTA_MAC" | awk '{print $1}' | head -n 1)
            if [ -n "$mac_ip" ]
            then
                conntrack -D -s "$mac_ip" 2>/dev/null
            fi
        fi
        return # 已超额，跳过后续计时逻辑
    fi

    # 4. 判断该设备此时是否具备上网条件（如果在全局断网期内且不在白名单内，设备连着WiFi也没网，不应计算其时长）
    local can_access_internet=1
    if [ "$LAST_STATE" = "DOWN" ]
    then
        local is_whitelisted=$(echo "$ALWAYS_ONLINE_MACS" | grep -i "$QUOTA_MAC")
        if [ -z "$is_whitelisted" ]
        then
            can_access_internet=0
        fi
    fi

    # 5. 如果具备上网条件，且在局域网内活跃 (ARP 状态为 REACHABLE, DELAY 或 STALE)，则累加时间
    if [ "$can_access_internet" -eq 1 ]
    then
        local is_online=$(ip neigh show | grep -i "$QUOTA_MAC" | egrep -i "REACHABLE|DELAY|STALE")
        if [ -n "$is_online" ]
        then
            used_time=$((used_time + INTERVAL))
            echo "$used_time" > "$QUOTA_FILE"
            # 取消下面这行的注释可观察实时计费日志，但会产生较多日志
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

    # 全局时间段管控状态切换
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
    
    # 每次循环执行一次特定 MAC 的日用时检查
    check_mac_quota
    
    sleep $INTERVAL
done
