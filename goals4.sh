# 户外园区
SESSION="goals"
if screen -list | grep -q "\.${SESSION}[[:space:]]"; then
    echo "[$SESSION] 已经在运行中，请先使用 goal_cancel.sh 关闭或等待结束。"
    exit 1
fi

echo "Launch multi_map_navigate_through_poses action in screen session [$SESSION]"

TMP_SCRIPT="/tmp/send_nav_goals_$$.sh"

cat << 'EOF' > "$TMP_SCRIPT"
ros2 action send_goal /multi_map_navigate_through_poses nav2_msgs/action/NavigateThroughPoses "{poses: [ \
 {header: {frame_id: 'zju1'}, pose: {position: {x: 266.7947, y:  -6.5418}, orientation: {z: -0.0086, w: 1.0000}}}, \
 {header: {frame_id: 'zju1'}, pose: {position: {x: 599.4360, y: -33.9102}, orientation: {z: -0.4168, w: 0.9090}}}, \
 {header: {frame_id: 'zju1'}, pose: {position: {x: 591.4183, y: -72.3708}, orientation: {z: -0.9861, w: 0.1662}}}, \
 {header: {frame_id: 'zju1'}, pose: {position: {x: 266.3288, y: -59.2163}, orientation: {z:  1.0000, w: 0.0000}}}, \
 {header: {frame_id: 'zju1'}, pose: {position: {x: -20.9350, y: -50.1975}, orientation: {z:  0.8817, w: 0.4719}}}, \
 {header: {frame_id: 'zju1'}, pose: {position: {x: -19.2913, y:  -0.0280}, orientation: {z:  0.2421, w: 0.9702}}}
]}"
EOF

chmod +x "$TMP_SCRIPT"

screen -dmS "$SESSION"
sleep 1

screen -x -S "$SESSION" -p 0 -X stuff "source $TMP_SCRIPT && rm $TMP_SCRIPT\n"