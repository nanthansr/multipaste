---
file: check_pb2.swift
size: 195
mtime: 2026-05-21T11:16:27.390937Z
sha256: 8edaa2aa99aaee65017028e0e894760fb36a9e87c63d809eabc9ae535c9d67e0
---

# check_pb2.swift

**Summary:** import AppKit

## Preview

```
import AppKit

let pb = NSPasteboard.general
print("Initial count: \(pb.changeCount)")
pb.clearContents()
pb.setString("test", forType: .string)
print("Count after setString: \(pb.changeCount)")
```
