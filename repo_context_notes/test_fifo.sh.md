---
file: test_fifo.sh
size: 939
mtime: 2026-05-21T11:20:13.849160Z
sha256: a438aa272b72af2d516fd9149042579593be70c3f34a9aebd993dae0b303566d
---

# test_fifo.sh

**Summary:** #!/bin/bash

## Preview

```
#!/bin/bash

echo "Starting multipaste..."
.build/debug/multipaste > app.log 2>&1 &
APP_PID=$!

echo "App PID: $APP_PID"
sleep 3

echo "Enabling FIFO mode via AppleScript..."
osascript -e 'tell application "System Events" to tell process "multipaste" to click menu item "Enable FIFO Mode" of menu 1 of menu bar item 1 of menu bar 2' || osascript -e 'tell application "System Events" to tell process "multipaste" to click menu item "Enable FIFO Mode" of menu 1 of menu bar item 1 of menu bar 1'
sleep 1

echo "Copying 'FIFO 1'..."
echo -n "FIFO 1" | pbcopy
sleep 1

echo "Copying 'FIFO 2'..."
echo -n "FIFO 2" | pbcopy
sleep 1

echo "Simulating Cmd+V..."
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
sleep 2

echo "Simulating Cmd+V..."
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
sleep 2

echo "Killing app..."
kill -9 $APP_PID

echo "App Log:"
cat app.log
```
