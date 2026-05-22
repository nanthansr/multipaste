---
file: Sources/multipaste/multipaste.swift
size: 326
mtime: 2026-05-21T11:12:16.056883Z
sha256: 39626e4c87e9af894d9ae2b4702584550c9234a814a2acb8301f1715aba8560a
---

# Sources/multipaste/multipaste.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import Darwin

@main
struct multipaste {
    static func main() {
        setbuf(stdout, nil)
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // Run as background app (no dock icon)
        app.run()
    }
}
```
