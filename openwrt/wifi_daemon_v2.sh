#!/bin/sh

# ================= 參數設置區 =================
# 第一段時間：03:00 開 --- 12:00 關
ON_1_H=3;  ON_1_M=0
OFF_1_H=12; OFF_1_M=0

# 第二段時間：13:30 開 --- 20:00 關
ON_2_H=13; ON_2_M=30
OFF_2_H=20; OFF_2_M=0

INTERVAL=60
# ==============================================

# 轉換時間為總分鐘數
T1_START=$((ON_1_H * 60 + ON_1_M))
T1_END=$((OFF_1_H * 60 + OFF_1_M))
T2_START=$((ON_2_H * 60 + ON_2_M))
T2_END=$((OFF_2_H * 60 + OFF_2_M))

# 等待時間同步
while [ "$(date +%Y)" -lt 2024 ]; do
    sleep 5
done
logger -t wifi_daemon "時間同步完成，開始多時段巡檢模式。"

LAST_STATE="UNKNOWN"

while true; do
    # 獲取當前小時和分鐘（處理前導零防止語法錯誤）
    CUR_H=$(date +%H | awk '{print int($0)}')
    CUR_M=$(date +%M | awk '{print int($0)}')
    CUR_VAL=$((CUR_H * 60 + CUR_M))

    TARGET_STATE="DOWN"

    # 核心判斷：只要滿足其中一個時間段，就應該開啟
    # 段1：[3:00, 12:00)
    if [ "$CUR_VAL" -ge "$T1_START" ] && [ "$CUR_VAL" -lt "$T1_END" ]; then
        TARGET_STATE="UP"
    # 段2：[13:30, 20:00)
    elif [ "$CUR_VAL" -ge "$T2_START" ] && [ "$CUR_VAL" -lt "$T2_END" ]; then
        TARGET_STATE="UP"
    fi

    # 執行動作
    if [ "$TARGET_STATE" != "$LAST_STATE" ]; then
        if [ "$TARGET_STATE" = "UP" ]; then
            logger -t wifi_daemon "進入允許上網時間段，開啟 WiFi"
            wifi up
        else
            logger -t wifi_daemon "進入禁網時間段，關閉 WiFi"
            wifi down
        fi
        LAST_STATE="$TARGET_STATE"
    fi

    sleep $INTERVAL
done
