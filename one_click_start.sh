#!/usr/bin/env zsh
# one_click_start.sh       -> 终端1—5
# one_click_start.sh robot -> 终端1—6

if [ $# -gt 1 ] || { [ $# -eq 1 ] && [ "$1" != "robot" ]; }; then
  echo -e "\e[31mError: Parameter must be 'robot'.\e[0m"
  exit 1
fi

source /opt/ros/noetic/setup.zsh
source ~/Workspace/driver_ws/devel/setup.zsh
source ~/Workspace/algor_ws/devel/setup.zsh

export ROS_IP=192.168.10.151
export ROS_MASTER_URI=http://192.168.10.151:11311

echo -e "\e[32mStarting roscore...\e[0m"
roscore &
sleep 2

echo -e "\e[32mStarting livox_ros_driver2...\e[0m"
roslaunch livox_ros_driver2 msg_MID360.launch &
sleep 2

echo -e "\e[32mStarting faster_lio...\e[0m"
roslaunch faster_lio mapping_mid360.launch localization_mode:=true prior_map_name:=PGO rviz:=false load_robot:=true &
sleep 2

echo -e "\e[32mStarting pointcloud_to_laserscan...\e[0m"
roslaunch pointcloud_to_laserscan mid360_rslidar.launch &
sleep 2

echo -e "\e[32mStarting r20_navigation...\e[0m"
roslaunch r20_navigation navigation.launch &
sleep 2

if [ "$1" = "robot" ]; then
  echo -e "\e[32mStarting tarkbot_robot...\e[0m"
  roslaunch tarkbot_robot robot.launch pub_odom_tf:=false &
else
  echo -e "\e[32mSkipping tarkbot_robot.\e[0m"
fi

echo -e "\e[32mSuccess: One-click start completed.\e[0m"
wait