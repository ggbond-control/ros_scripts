SESSION="goals"
if screen -list | grep -q "\.${SESSION}[[:space:]]"; then
    echo "[$SESSION] 已经在运行中，请先使用 goal_cancel.sh 关闭或等待结束。"
    exit 1
fi

echo "Launch multi_map_navigate_through_poses action in screen session [$SESSION]"
screen -dmS "$SESSION"
sleep 1
screen -x -S "$SESSION" -p 0 -X stuff "ros2 action send_goal /multi_map_navigate_through_poses nav2_msgs/action/NavigateThroughPoses \"{poses: [ \
 {header: {frame_id: 'zju20'}, pose: {position: {x:  0.5, y: 0.32}, orientation: {z: 0.000, w: 1.000}}}, \
 {header: {frame_id: 'zju20', stamp: {sec: 1}}, pose: {position: {x: 4.60556273, y: -0.279198}, orientation: {z:  -0.630, w: 0.77589}}}, \
 {header: {frame_id: 'zju20', stamp: {sec: 1}}, pose: {position: {x: 2.141515, y: -6.377280}, orientation: {z:  -1.0, w: 0.0}}}, \
 {header: {frame_id: 'zju20'}, pose: {position: {x:  0.5, y: 0.32}, orientation: {z: 0.000, w: 1.000}}}
]}\"\n"
