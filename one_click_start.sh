#!/bin/bash

# ===============================================
# 配置定义（编号 | 会话名 | 备注 | 启动命令 | 期望节点）
# ===============================================
CONFIG=(
  "1 | tarkbot    | 底盘驱动 | source ~/Workspace/driver_ws/install/setup.zsh && ros2 launch tarkbot_robot robot.launch.py pub_odom_tf:=false                                                                                                          | /tarkbot_robot"
  "2 | livox      | 雷达驱动 | source ~/Workspace/driver_ws/install/setup.zsh && ros2 launch livox_ros_driver2 msg_MID360_launch.py                                                                                                                    | /livox_lidar_publisher"
  "3 | lio        | 定位算法 | source ~/Workspace/algor_ws/install/setup.zsh  && ros2 launch faster_lio slam.launch.py relocal:=true prior_dir:=company                                                                                                | /laser_mapping"
  "4 | gridmapper | 建图算法 | source ~/Workspace/algor_ws/install/setup.zsh  && ros2 launch gridmapper local.launch.py rviz:=false                                                                                                                    | /gridmapper_node"
  "5 | nav        | 全局规划 | source ~/Workspace/algor_ws/install/setup.zsh  && ros2 launch multi_map_nav multi_map_nav.launch.py initial_map:=company map_connections_file:=company use_fake_cmdvel:=true params_file:=new_local use_sim_time:=false | /planner_server /controller_server"
  "6 | planner    | 局部规划 | source ~/Workspace/algor_ws/install/setup.zsh  && ros2 launch local_planner local_planner.launch.py use_sim_time:=false start_rviz:=false debug_info:=true                                                              | /localPlanner /pathFollower"
  "7 | goal       | 目标发布 | source ~/Workspace/algor_ws/install/setup.zsh  && ros2 run multi_map_nav goal_publisher.py                                                                                                                              | /multi_goal_navigation"
)

trim() {
    local var="$*"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

operate() {
    local action=$1
    local target_id=$2
    
    printf "%s\n" "${CONFIG[@]}" | sort -n | while IFS='|' read -r id name desc cmd nodes; do
        
        id=$(trim "$id")
        name=$(trim "$name")
        cmd=$(trim "$cmd")
        nodes=$(trim "$nodes")

        if [[ "$target_id" == "all" || "$target_id" == "$id" ]]; then
            if [ "$action" == "start" ]; then
                if screen -list | grep -q "\.${name}[[:space:]]"; then
                    echo "[$name] 已在运行"
                else
                    echo "[$name] ($desc) 启动中..."
                    screen -dmS "$name" bash -c "$cmd"
                    wait_nodes "$name" "$nodes"
                fi
            else
                if screen -list | grep -q "\.${name}[[:space:]]"; then
                    screen -S "$name" -X quit && echo "[$name] 已停止"
                else
                    echo "[$name] 未运行"
                fi
            fi
        fi
    done
}

show_menu() {
    printf "%s\n" "${CONFIG[@]}" | sort -n | while IFS='|' read -r id name desc cmd nodes; do
        printf "  \033[1;32m%s)\033[0m %-12s \033[36m# %s\033[0m\n" "$(trim "$id")" "$(trim "$name")" "$(trim "$desc")"
    done
    printf "  \033[1;32ma)\033[0m %-12s \033[36m# 启动/停止全部\033[0m\n" "all"
    printf "  \033[1;31mq)\033[0m %-12s \033[36m# 退出\033[0m\n" "quit"
    echo ""
}

wait_nodes() {
    local name=$1 nodes=$2 timeout=10
    echo -n "[$name] 验证节点..."
    for ((i=0; i<timeout; i++)); do
        local cur=$(ros2 node list 2>/dev/null)
        local ok=true
        for n in $nodes; do if ! echo "$cur" | grep -qx "$n" >/dev/null; then ok=false; break; fi; done
        if [ "$ok" = true ]; then echo -e "\033[32m 已就绪\033[0m"; return 0; fi
        sleep 1
    done
    echo -e "\033[31m 超时\033[0m"; return 1
}

case "$1" in
    start|stop)
        show_menu
        read -p "请输入指令 [ $1 ]: " choice
        case $choice in
            a|all) operate $1 "all" ;;
            q|quit|exit) exit 0 ;;
            *) operate $1 "$choice" ;;
        esac
        ;;
    status)
        screen -list
        ;;
    *)
        echo "Usage: $0 [start|stop|status]"
        ;;
esac