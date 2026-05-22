---
file: test_loop.sh
size: 586
mtime: 2026-05-21T11:11:33.526259Z
sha256: 2ca31856f015fa8252d7cc28cd6e0d4897657c01aa6d1c9f2b163b1627398e04
---

# test_loop.sh

**Summary:** #!/bin/bash

## Preview

```
#!/bin/bash

echo "Starting multipaste..."
.build/debug/multipaste > app.log 2>&1 &
APP_PID=$!

echo "App PID: $APP_PID"
sleep 2

echo "Copying 'Clip 1'..."
echo -n "Clip 1" | pbcopy
sleep 1

echo "Copying 'Clip 2'..."
echo -n "Clip 2" | pbcopy
sleep 1

echo "Simulating Cmd+Shift+V..."
osascript -e 'tell application "System Events" to keystroke "v" using {command down, shift down}'
sleep 2

echo "Simulating Cmd+V..."
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
sleep 2

echo "Killing app..."
kill -INT $APP_PID

echo "App Log:"
cat app.log
```
