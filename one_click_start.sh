#!/usr/bin/env zsh
# one_click_start.sh [start|stop|restart|status] [1|2|3|4|5|6|7|all]

declare -A SESSIONS=(
  [1]="tarkbot"
  [2]="livox"
  [3]="lio"
  [4]="gridmapper"
  [5]="nav"
  [6]="planner"
  [7]="goal"
)

declare -A COMMANDS=(
  [1]="source ~/Workspace/driver_ws/install/setup.zsh && ros2 launch tarkbot_robot robot.launch.py pub_odom_tf:=false"
  [2]="source ~/Workspace/driver_ws/install/setup.zsh && ros2 launch livox_ros_driver2 msg_MID360_launch.py"
  [3]="source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch faster_lio slam.launch.py relocal:=true prior_dir:=company"
  [4]="source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch gridmapper local.launch.py rviz:=false"
  [5]="source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch multi_map_nav multi_map_nav.launch.py initial_map:=company map_connections_file:=company use_fake_cmdvel:=true params_file:=new_local use_sim_time:=false"
  [6]="source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch local_planner local_planner.launch.py use_sim_time:=false start_rviz:=false debug_info:=true"
  [7]="source ~/Workspace/algor_ws/install/setup.zsh && ros2 run multi_map_nav goal_publisher.py"
)

if ! command -v screen &>/dev/null; then
  echo "Command 'screen' not found, but can be installed with:"
  echo "sudo apt install screen"
  exit 1
fi

start_one() {
  local id=$1
  local name="${SESSIONS[$id]}"
  local cmd="${COMMANDS[$id]}"
  if screen -list | grep -q "$name"; then
    echo "[$name] Already running, skip start."
  else
    echo "[$name] Starting..."
    screen -dmS "$name" bash -c "$cmd"
    echo "[$name] Started successfully."
  fi
}

stop_one() {
  local id=$1
  local name="${SESSIONS[$id]}"
  if screen -list | grep -q "$name"; then
    echo "[$name] Stopping..."
    screen -S "$name" -X quit
    echo "[$name] Stopped successfully."
  else
    echo "[$name] Not running, skip stop."
  fi
}

status_one() {
  local id=$1
  local name="${SESSIONS[$id]}"
  if screen -list | grep -q "$name"; then
    echo "[$name] Attaching..."
    screen -r "$name"
  else
    echo "[$name] Not running, cannot attach."
  fi
}

status_all() {
  screen -list
}

ACTION=$1
TARGET=$2

if [[ -z $ACTION ]]; then
  echo "Usage: one_click_start.sh [start|stop|restart|status] [1|2|3|4|5|6|7|all]"
  exit 0
fi

case $ACTION in
  start)
    if [[ $TARGET == "all" ]]; then
      start_one 1; start_one 2; sleep 2
      start_one 3; start_one 4; sleep 2
      start_one 5; start_one 6; sleep 2
      start_one 7
    else
      start_one $TARGET
    fi
    ;;
  stop)
    if [[ $TARGET == "all" ]]; then
      for i in {1..7}; do stop_one $i; done
    else
      stop_one $TARGET
    fi
    ;;
  restart)
    if [[ $TARGET == "all" ]]; then
      for i in {1..7}; do stop_one $i; done
      sleep 1
      start_one 1; start_one 2; sleep 2
      start_one 3; start_one 4; sleep 2
      start_one 5; start_one 6; sleep 2
      start_one 7
    else
      stop_one $TARGET
      sleep 1
      start_one $TARGET
    fi
    ;;
  status)
    if [[ -z $TARGET || $TARGET == "all" ]]; then
      status_all
    else
      status_one $TARGET
    fi
    ;;
  *)
    echo "Usage: one_click_start.sh [start|stop|restart|status] [1|2|3|4|5|6|7|all]"
    ;;
esac
