#!/bin/sh

# Check for screen sessions
if screen -ls | grep -q "No Sockets found"; then
    echo "No screen sessions found"
    exit 0
fi

# List sessions with numbers
echo "Screen sessions:"
i=1
# Store sessions in a temporary file to avoid subshell issues
screen -ls | grep -E '(Detached|Attached)' > /tmp/screen_sessions
while read line; do
    session=$(echo "$line" | awk '{print $1}')
    name_part=$(echo "$session" | cut -d. -f2-)
    if echo "$name_part" | grep -iq "motor"; then
        # 包含 motor → 跳过，不加入列表，也不编号
        continue
    fi
    status=$(echo "$line" | grep -oE '(Detached|Attached)')
    echo "$i: $session ($status)"
    eval "session_$i=$session"
    i=$((i + 1))
done < /tmp/screen_sessions

# Get total sessions
total=$((i - 1))

# Clean up temporary file
rm -f /tmp/screen_sessions

# Prompt for session numbers
echo "Enter session numbers to delete (space-separated, 0 for all):"
read input

# Process input
if [ "$input" = "0" ]; then
    screen -ls | grep -E '(Detached|Attached)' | awk '{print $1}' | while read session; do
        if echo “$session” | grep -iq "[0-9][0-9]*\.motor"; then
            continue
        fi
        echo "Deleting session: $session"
        screen -S "$session" -p 0 -X stuff "^C"
        sleep 1
        screen -S "$session" -X quit
    done
    echo "All sessions deleted"
else
    for num in $input; do
        if [ "$num" -ge 1 ] && [ "$num" -le "$total" ]; then
            eval "session=\$session_$num"
            echo "Deleting session: $session"
            screen -S "$session" -p 0 -X stuff "^C"
            sleep 1
            screen -S "$session" -X quit
        else
            echo "Invalid number: $num (valid: 1-$total)"
        fi
    done
    echo "Selected sessions deleted"
fi