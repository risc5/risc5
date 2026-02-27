#!/bin/sh

# ================= 參數設置區 =================
# 設定開啟 WiFi 的時間 (24小時制)
ON_HOUR=4
ON_MIN=0

# 設定關閉 WiFi 的時間 (24小時制)
OFF_HOUR=20
OFF_MIN=0
sleep 80
# 每次檢查的時間間隔（秒），60秒足夠及時且不耗CPU
INTERVAL=60
# ==============================================

# 1. 轉換時間為「一天中的總分鐘數」，方便數值比較
ON_VAL=$((ON_HOUR * 60 + ON_MIN))
OFF_VAL=$((OFF_HOUR * 60 + OFF_MIN))

# 2. 啟動防護：等待系統 NTP 時間同步
# 路由器斷電重啟後，時間通常會回到 1970 年。
# 如果不等待同步直接執行，會導致誤判。
logger -t wifi_daemon "等待系統時間同步..."
while [ "$(date +%Y)" -lt 2024 ]; do
    sleep 5
done
logger -t wifi_daemon "時間同步完成，啟動 WiFi 狀態巡檢。"

# 記錄上一次的執行狀態，避免每 60 秒重複下達開啟/關閉指令導致斷網
LAST_STATE="UNKNOWN"

# 3. 進入無限循環巡檢
while true; do
    # 獲取當前時間（利用 awk 去除前導零，防止 BusyBox 將 08/09 當成錯誤的八進制數字）
    CUR_H=$(date +%H | awk '{print int($0)}')
    CUR_M=$(date +%M | awk '{print int($0)}')
    CUR_VAL=$((CUR_H * 60 + CUR_M))

    TARGET_STATE="DOWN" # 默認狀態為關閉

    # 4. 核心邏輯判斷（支援常規時間段，也支援跨夜時間段）
    if [ "$ON_VAL" -lt "$OFF_VAL" ]; then
        # 常規設定：例如 3:00 開，20:00 關
        if [ "$CUR_VAL" -ge "$ON_VAL" ] && [ "$CUR_VAL" -lt "$OFF_VAL" ]; then
            TARGET_STATE="UP"
        fi
    else
        # 跨天設定：例如 20:00 開，3:00 關
        if [ "$CUR_VAL" -ge "$ON_VAL" ] || [ "$CUR_VAL" -lt "$OFF_VAL" ]; then
            TARGET_STATE="UP"
        fi
    fi

    # 5. 執行動作：只有當「目標狀態」與「當前狀態」不一致時，才執行命令
    if [ "$TARGET_STATE" != "$LAST_STATE" ]; then
        if [ "$TARGET_STATE" = "UP" ]; then
            logger -t wifi_daemon "當前時間在開啟區間，執行: wifi up"
            wifi up
        else
            logger -t wifi_daemon "當前時間不在開啟區間，執行: wifi down"
            wifi down
        fi
        # 更新狀態記錄
        LAST_STATE="$TARGET_STATE"
    fi

    # 休眠等待下一次檢查
    sleep $INTERVAL
done
