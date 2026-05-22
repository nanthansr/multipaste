---
file: check_pb4.swift
size: 352
mtime: 2026-05-21T11:16:59.789345Z
sha256: 6ab2c4a4d4cb1095486dc46026c780832599c4571ce59580e22f698053e9aacf
---

# check_pb4.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import Foundation

let pb = NSPasteboard.general
print("Initial count: \(pb.changeCount)")
pb.clearContents()
pb.setString("test", forType: .string)
print("Count after setString: \(pb.changeCount)")

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
    print("Count after 0.5s: \(pb.changeCount)")
    exit(0)
}
RunLoop.main.run()
```
