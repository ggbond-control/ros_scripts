SESSION="goal"
if screen -list | grep -q "\.${SESSION}[[:space:]]"; then
    echo "[$SESSION] 已经在运行中，请先使用 goal_cancel.sh 关闭或等待结束。"
    exit 1
fi

echo "Launch multi_map_navigate_to_pose action in screen session [$SESSION]"
screen -dmS "$SESSION"
sleep 1
screen -x -S "$SESSION" -p 0 -X stuff "ros2 action send_goal /multi_map_navigate_to_pose nav2_msgs/action/NavigateToPose \"{
pose: {header: {frame_id: 'company'},pose: {position: {x: 31.5, y: 20.2},orientation: {z: 0.0, w: 1.0}}}}\"\n"
