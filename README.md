# Scripts

## Screen Usage

| Scripts Name | Description                       |
|--------------|-----------------------------------|
| `clear_session.screen.sh` | Clear all or selected existing screen sessions |
| `slam.screen.sh` | Automatically start several sessions as lidar, tarkbot and slam |

```sh
# Start a new screen session named <session_name>
screen -S <session_name>

# List all screen sessions
screen -ls

# Reattach to a screen session named <session_name>
screen -r <session_name>

# press Ctrl+A, then D to detach the current session
# press Ctrl+A, then K to kill the current session
# press Ctrl+A, then [ to enter copy mode and use scroll wheel or arrow keys to scroll up and down
```

