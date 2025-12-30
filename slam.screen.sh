#!/bin/sh
echo "Launch livox_ros_driver2 in screen session [lidar]"
screen -dmS lidar
screen -S lidar -X stuff "ros2 launch livox_ros_driver2 msg_MID360_launch.py\n"

sleep 2

echo "Launch tarkbot_robot in screen session [tarkbot]"
screen -dmS tarkbot
screen -x -S tarkbot -p 0 -X stuff "ros2 launch tarkbot_robot robot.launch.py pub_odom_tf:=false\n"
sleep 1

echo "Launch faster_lio in screen session [slam]"
screen -dmS slam
screen -x -S slam -p 0 -X stuff "source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch faster_lio mapping_mid360.launch.py localization_mode:=true load_robot:=false prior_map_name:=PGO rviz:=false\n"
sleep 8

echo "Launch gridmapper in screen session [gridmapper]"
screen -dmS gridmapper
screen -x -S gridmapper -p 0 -X stuff "source ~/Workspace/algor_ws/install/setup.zsh && ros2 launch gridmapper local.launch.py rviz:=false\n"
sleep 2

echo "All screen sessions launched"
echo "=================================================="
echo "Plz use the following command to check odometry!!!"
echo "ros2 topic echo /odometry_gra_horizon | grep posi -A3"