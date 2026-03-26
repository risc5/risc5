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

sleep 80
# 每次检查的时间间隔（秒）
INTERVAL=60
# ==============================================

ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))

logger -t self_control_daemon "等待系统时间同步..."

# [针对 BusyBox 优化]：将 do 换行，彻底避免解析错误
while [ "$(date +%Y)" -lt 2024 ]
do
    sleep 5
done

logger -t self_control_daemon "时间同步完成，启动自我约束巡检。"

# ================= 防火墙控制函数 =================
update_firewall_rule() {
    local state=$1
    
    # 清理旧规则
    uci -q delete firewall.allow_iot
    uci -q delete firewall.block_self
    
    # [针对 BusyBox 优化]：将 then 换行
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
            logger -t self_control_daemon "当前时间在放行区间，解除网络约束"
            update_firewall_rule "UP" 
        else
            logger -t self_control_daemon "【注意】进入约束时间！已阻断自身设备网络"
            update_firewall_rule "DOWN"
        fi
        LAST_STATE="$TARGET_STATE"
    fi
    
    sleep $INTERVAL
done