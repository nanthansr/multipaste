---
file: Sources/multipaste/TooltipView.swift
size: 1314
mtime: 2026-05-21T02:28:37.636368Z
sha256: 14cdc75bcbeca97e5dc2cceeb94a6a6f8b0d129244447b613251ec5db125e55b
---

# Sources/multipaste/TooltipView.swift

**Summary:** import SwiftUI

## Preview

```
import SwiftUI

struct TooltipView: View {
    var content: String
    var index: Int
    var total: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(index + 1)/\(total)")
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Text(content)
                .font(.system(size: 13, weight: .medium, design: .monospaced))
                .lineLimit(3)
                .foregroundColor(.primary)
        }
        .padding(8)
        .background(VisualEffectView(material: .popover, blendingMode: .behindWindow))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        .frame(width: 250, alignment: .leading)
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
```
