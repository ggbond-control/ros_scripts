# ROS 脚本工具库

本仓库包含一组用于管理 ROS2 导航任务的实用脚本，通过 `screen` 实现后台运行与会话管理。

## 脚本概览

| 脚本名称           | 描述                                                                       |
| ------------------ | -------------------------------------------------------------------------- |
| `navigate.sh`      | 主控制脚本，用于在 `screen` 中启动/停止导航模块。支持多种机器人/地图模式。 |
| `clear_session.sh` | 交互式清理工具，用于清理现有的 `screen` 会话。                             |
| `goal.sh`          | 向机器人发送单个导航目标点 (`NavigateToPose`)。                            |
| `goals.sh`         | 向机器人发送一系列导航目标点 (`NavigateThroughPoses`)，用于巡逻任务。      |
| `goal_cancel.sh`   | 优雅地停止当前活跃的 `goal` 或 `goals` 会话。                              |

## 导航管理 (`navigate.sh`)

`navigate.sh` 是管理导航相关模块（雷达驱动、SLAM、路径规划等）的主要入口。

### 使用方法
```sh
./navigate.sh [start|stop|status] [mode] [id]
```

- **动作 (Action)**: `start` (启动), `stop` (停止), `status` (查看状态)
- **模式 (Mode)**:
  - `car+map`: 适用于 tarkbot 机器人的全功能导航（含重定位）。
  - `car-map`: tarkbot 导航（仅雷达 + SLAM + 局部规划，不加载全局地图）。
  - `dog+map`: 适用于四足机器人的全功能导航（含重定位）。
  - `dog-map`: 四足机器人导航（不加载全局地图）。
- **编号 (ID)**: 具体的模块编号 (1-6) 或 `all` (全部)。

### 示例
```sh
# 以 car+map 模式启动所有导航模块
./navigate.sh start car+map all

# 仅停止雷达驱动模块 (编号 2)
./navigate.sh stop car+map 2
```

## Screen 使用技巧

### 基础命令
```sh
# 启动一个名为 <session_name> 的新会话
screen -S <session_name>

# 列出所有 screen 会话
screen -ls

# 重新连接到名为 <session_name> 的会话
screen -r <session_name>
```

### 快捷键 (在 screen 会话内部时使用)
- `Ctrl+A, 然后 D`: 分离会话（会话在后台继续运行）。
- `Ctrl+A, 然后 K`: 杀死当前会话。
- `Ctrl+A, 然后 [`: 进入复制/滚动模式（可使用鼠标滚轮或方向键上下滚动查看日志）。
- `Ctrl+C`: 终止当前会话中正在运行的进程。
