---
file: check_pb5.swift
size: 669
mtime: 2026-05-21T11:17:19.581343Z
sha256: f546bd98b4f47ce246527f538c7f3f7ceeddd9f972a56a0ec705601eeb270ebd
---

# check_pb5.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import Foundation

let pb = NSPasteboard.general
print("Initial count: \(pb.changeCount)")

// Simulate Cmd+V
let vKeyCode: CGKeyCode = 9
guard let source = CGEventSource(stateID: .hidSystemState) else { exit(1) }
let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
cmdDown?.flags = .maskCommand
let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
cmdUp?.flags = .maskCommand
cmdDown?.post(tap: .cghidEventTap)
cmdUp?.post(tap: .cghidEventTap)

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    print("Count after paste: \(pb.changeCount)")
    exit(0)
}
RunLoop.main.run()
```
