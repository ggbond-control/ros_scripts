#!/bin/bash
set -e

# ROS 环境
source /opt/ros/jazzy/setup.bash
source /home/cat/jazzy_ws/install/setup.bash

export ROS_DOMAIN_ID=26
export ROS_LOCALHOST_ONLY=0

echo "[INFO] Launching motor bridge..."
ros2 launch unitree_motor_hw motor_bridge.launch.py &
MOTOR_BRIDGE_PID=$!

sleep 4

echo "stop navgation system, shut all nav nodes"
bash /home/cat/Scripts/ros_scripts/navigate.sh stop dog+map all

sleep 2

bash /home/cat/Scripts/ros_scripts/navigate.sh start dog+map all

sleep 3

source /home/cat/ros2_ws/install/setup.bash
ros2 run ros2_mqtt_bridge mqtt_bridge_node &
MQTT_BRIDGE_PID=$!

wait
