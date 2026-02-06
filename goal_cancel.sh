#!/bin/bash

# ===============================================
# goal_cancel.sh - 关闭 goal 和 goals 会话
# ===============================================

TARGET_SESSIONS=("goal" "goals")

# 第一阶段：发送 Ctrl+C (SIGINT)
echo "正在尝试关闭目标会话: ${TARGET_SESSIONS[*]}"
ACTIVE_TRACKER=()

for session in "${TARGET_SESSIONS[@]}"; do
    if screen -ls | grep -q "\.${session}[[:space:]]"; then
        echo "[$session] 发送 Ctrl+C (SIGINT)..."
        screen -S "$session" -p 0 -X stuff "^C"
        ACTIVE_TRACKER+=("$session")
    else
        echo "[$session] 未在运行"
    fi
done

if [ ${#ACTIVE_TRACKER[@]} -eq 0 ]; then
    echo "没有活跃的会话需要关闭。"
    exit 0
fi

# 等待几秒
echo "等待 1 秒允许节点退出..."
sleep 3

# 第二阶段：发送 quit 命令
for session in "${ACTIVE_TRACKER[@]}"; do
    if screen -ls | grep -q "\.${session}[[:space:]]"; then
        echo "[$session] 正在强制关闭 (quit)..."
        screen -S "$session" -X quit
    else
        echo "[$session] 已自行退出"
    fi
done

echo "完成。"
