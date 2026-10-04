#!/usr/bin/env bash
# macOS Clamshell/Sleep Event & CPU Watchdog with Sleepimage Verification

LOG_FILE="./sleep_monitor_$(date "+%Y%m%d_%H%M%S").log"
SLEEP_IMAGE="/var/vm/sleepimage"
CPU_THRESHOLD=50
INTERVAL=3

echo "=== 启动休眠状态机与 CPU 监控 [PID: $$] ===" | tee -a "$LOG_FILE"
echo "日志输出目标: $LOG_FILE" | tee -a "$LOG_FILE"

# 初始化检测 sleepimage 状态与修改时间戳 (Epoch)
if [ -f "$SLEEP_IMAGE" ]; then
    INIT_IMG_INFO=$(ls -lh "$SLEEP_IMAGE" 2>/dev/null)
    PREV_IMG_MTIME=$(stat -f %m "$SLEEP_IMAGE" 2>/dev/null || echo 0)
    echo "初始 sleepimage 镜像状态: $INIT_IMG_INFO" | tee -a "$LOG_FILE"
else
    PREV_IMG_MTIME=0
    echo "警告: 未检测到 $SLEEP_IMAGE (请确认是否以 sudo 运行或已分配虚拟内存)" | tee -a "$LOG_FILE"
fi

trap 'echo "=== 监控停止: $(date "+%Y-%m-%d %H:%M:%S") ===" >> "$LOG_FILE"; exit 0' SIGINT SIGTERM

PREV_LID_STATE=""
LAST_EPOCH=$(date +%s)

while true; do
    TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
    NOW_EPOCH=$(date +%s)
    TIME_DIFF=$((NOW_EPOCH - LAST_EPOCH))

    # 1. 深度休眠/挂起唤醒感知（通过时钟跳变判断）
    # 当系统真正进入 S4 磁盘休眠或暂停时，循环线程挂起；唤醒恢复时时间差将远大于执行周期
    if [ "$TIME_DIFF" -gt $((INTERVAL + 5)) ]; then
        CURR_IMG_MTIME=$(stat -f %m "$SLEEP_IMAGE" 2>/dev/null || echo 0)
        CURR_IMG_INFO=$(ls -lh "$SLEEP_IMAGE" 2>/dev/null)

        {
            echo "=================================================="
            echo "[$TIMESTAMP] >>> 系统唤醒感知 (休眠挂起时长: ${TIME_DIFF} 秒) <<<"
            if [ "$CURR_IMG_MTIME" -gt "$PREV_IMG_MTIME" ]; then
                WRITE_TIME=$(date -r "$CURR_IMG_MTIME" "+%Y-%m-%d %H:%M:%S")
                echo "[NVMe 落盘验证]: 【已成功写入】检测到 sleepimage 镜像落盘！"
                echo "  - 落盘完成时间: $WRITE_TIME"
                echo "  - 镜像物理信息: $CURR_IMG_INFO"
                PREV_IMG_MTIME="$CURR_IMG_MTIME"
            else
                echo "[NVMe 落盘验证]: 【未写入 / 仅浅睡】sleepimage 修改时间未发生变动"
                echo "  - 当前镜像信息: $CURR_IMG_INFO"
            fi
            echo "=================================================="
        } >> "$LOG_FILE"
    fi
    LAST_EPOCH="$NOW_EPOCH"

    # 2. 毫秒级读取硬件闭合状态
    RAW_LID=$(ioreg -r -k AppleClamshellState 2>/dev/null | awk -F'= ' '/"AppleClamshellState"/{print $2}')
    LID_STATE="${RAW_LID:-Unknown}"

    # 3. 边沿跳变触发：捕获 LidClose / LidOpen 瞬态事件
    if [ -n "$PREV_LID_STATE" ] && [ "$LID_STATE" != "$PREV_LID_STATE" ]; then
        if [ "$LID_STATE" = "Yes" ]; then
            EVENT_TYPE="[EVENT: LidClose (屏幕闭合)]"
        else
            EVENT_TYPE="[EVENT: LidOpen (屏幕掀开)]"
        fi

        RECENT_POWER_LOG=$(pmset -g log | grep -E "Clamshell|LidOpen|LidClose|Wake reason|Entering Sleep" | tail -n 5)
        CURR_IMG_INFO=$(ls -lh "$SLEEP_IMAGE" 2>/dev/null)

        {
            echo "=================================================="
            echo "[$TIMESTAMP] >>> 传感器状态跳变: $EVENT_TYPE <<<"
            echo "实时 sleepimage 状态: $CURR_IMG_INFO"
            echo "最近电源事件 (pmset log):"
            echo "$RECENT_POWER_LOG"
            echo "=================================================="
        } >> "$LOG_FILE"
    fi
    PREV_LID_STATE="$LID_STATE"

    # 4. 检查节流与阻睡断言
    CPU_LIMIT=$(pmset -g therm 2>/dev/null | awk '/CPU_Speed_Limit/{print $3}')
    [ -z "$CPU_LIMIT" ] && CPU_LIMIT="N/A"

    ACTIVE_ASSERTIONS=$(pmset -g assertions 2>/dev/null | awk '
        /PreventUserIdleSystemSleep/ || /PreventSystemSleep/ {
            if ($2 != 0) print $1
        }
        /Listed by owning process/ {flag=1; next}
        flag && /pid [0-9]+/ {print $0}
    ' | tr '\n' ' | ' | sed 's/ | $//')
    [ -z "$ACTIVE_ASSERTIONS" ] && ACTIVE_ASSERTIONS="None"

    # 5. 获取 CPU 占用最高的进程
    TOP_PROCS=$(ps -A -o pid=,%cpu=,comm= -r | head -n 5)
    HIGHEST_CPU=$(echo "$TOP_PROCS" | head -n 1 | awk '{print int($2)}')

    # 6. 异常记录条件：合盖状态 或 CPU 突破阈值
    if [ "$LID_STATE" = "Yes" ] || [ "${HIGHEST_CPU:-0}" -ge "$CPU_THRESHOLD" ]; then
        {
            echo "--------------------------------------------------"
            echo "[$TIMESTAMP] LID_STATE: $LID_STATE | CPU_SPEED_LIMIT: ${CPU_LIMIT}%"
            echo "ASSERTIONS: $ACTIVE_ASSERTIONS"
            echo "TOP 5 PROCESSES:"
            echo "$TOP_PROCS" | awk '{printf "  PID: %-7s CPU: %-5s %%  CMD: %s\n", $1, $2, $3}'

            if [ "$LID_STATE" = "Yes" ] && [ "${HIGHEST_CPU:-0}" -ge "$CPU_THRESHOLD" ]; then
                TARGET_PID=$(echo "$TOP_PROCS" | head -n 1 | awk '{print $1}')
                echo "  [ALERT] 闭盖持续高载 -> PID $TARGET_PID 详情:"
                ps -p "$TARGET_PID" -o pid,ppid,user,args 2>/dev/null | tail -n 1 | awk '{print "  " $0}'
            fi
        } >> "$LOG_FILE"
    fi

    sleep "$INTERVAL"
done
