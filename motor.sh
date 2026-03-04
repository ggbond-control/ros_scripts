#!/usr/bin/env bash

set -u   # 未定义变量视为错误
set -e   # 命令失败立即退出（部分地方会用 || true 绕过）

# ────────────────────────────────────────────────
# 辅助函数：等待特定 ROS2 节点出现 / 消失
# ────────────────────────────────────────────────

wait_node_up() {
    local node="/lcm_motor_bridge"
    local timeout=5
    local interval=0.8

    echo -n "[motor] 等待节点 ${node} 出现 "

    for ((i=0; i<timeout; i++)); do
        if ros2 node list 2>/dev/null | grep -Fx "${node}" >/dev/null; then
            echo -e "\033[32m已检测到\033[0m"
            return 0
        fi
        echo -n "."
        sleep "${interval}"
    done

    echo -e "\033[31m 超时（${timeout}秒）\033[0m"
    return 1
}

wait_node_down() {
    local node="/lcm_motor_bridge"
    local timeout=5
    local interval=0.8

    echo -n "[motor] 等待节点 ${node} 消失 "

    for ((i=0; i<timeout; i++)); do
        if ! ros2 node list 2>/dev/null | grep -Fx "${node}" >/dev/null; then
            echo -e "\033[32m已关闭\033[0m"
            return 0
        fi
        echo -n "."
        sleep "${interval}"
    done

    echo -e "\033[31m 关闭超时（${timeout}秒）\033[0m"
    return 1
}

# ────────────────────────────────────────────────
# 第一阶段：清理所有名称包含 "motor" 的旧 screen
# ────────────────────────────────────────────────

echo "检查是否存在含 'motor' 的 screen 会话..."

if screen -ls | grep -q "[0-9][0-9]*\.motor"; then
    echo "发现含 'motor' 的 screen，正在逐个清理..."

    # 找出所有匹配的 session（更精确匹配 .motor 结尾或含 motor）
    screen -ls | grep "motor" | awk '{print $1}' | while read -r session; do
        echo "  → 正在关闭 session: ${session}"

        # 尝试发送 Ctrl+C
        screen -S "${session}" -p 0 -X stuff $'\003'  2>/dev/null || true
        sleep 1

        # 等待节点消失（核心验证点）
        if wait_node_down; then
            # 节点已消失 → 安全关闭 screen
            screen -S "${session}" -X quit 2>/dev/null || true
        else
            echo "  警告：节点未及时关闭，强制销毁 screen"
            screen -S "${session}" -X quit 2>/dev/null || true
            sleep 1
        fi
    done

    # 最终双重确认
    sleep 1
    if screen -ls | grep -q "motor"; then
        echo "警告：仍有含 'motor' 的 screen 未完全清理，请手动检查"
    else
        echo "所有含 'motor' 的旧 screen 已清理"
    fi
else
    echo "No screen motor found"
fi

# ────────────────────────────────────────────────
# 第二阶段：启动全新的 motor screen
# ────────────────────────────────────────────────

echo ""
echo "[motor] motor drive 启动中..."

# 创建 detached screen，名称严格为 motor
screen -dmS motor

# 发送启动命令（注意：这里假设命令不需要 sudo，且环境已 source）
screen -S motor -p 0 -X stuff "ros2 launch unitree_motor_hw motor_bridge.launch.py\n"

echo "已创建 screen 'motor' 并发送启动命令"

# 等待节点启动（核心验证点）
if wait_node_up; then
    echo ""
    echo "启动流程完成，/lcm_motor_bridge 节点已在线"
    echo "查看 screen：  screen -r motor"
    echo "在 screen 内按 Ctrl+A D 脱离，按 Ctrl+C 停止程序"
else
    echo ""
    echo "警告：启动超时，/lcm_motor_bridge 节点未出现"
    echo "请执行 screen -r motor 查看是否有错误输出"
    exit 1
fi

exit 0