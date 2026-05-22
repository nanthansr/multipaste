---
file: check_pb3.swift
size: 241
mtime: 2026-05-21T11:16:49.570207Z
sha256: 1111355369f742a5189bb03bd4e5b8385c8b2d3856a4dc807ea745eb9bd462b4
---

# check_pb3.swift

**Summary:** import AppKit

## Preview

```
import AppKit

let pb = NSPasteboard.general
print("Initial count: \(pb.changeCount)")
pb.clearContents()
print("Count after clear: \(pb.changeCount)")
pb.setString("test", forType: .string)
print("Count after setString: \(pb.changeCount)")
```
