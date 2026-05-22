import re

# 1. AppDelegate.swift
with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()
ad = ad.replace("var clips: [(id: Int64, content: String, type: String, timestamp: Date)] = []", "var clips: [Clip] = []")
ad = ad.replace("TooltipManager.shared.showTooltip(content: clip.content, index: currentIndex, total: clips.count)", "TooltipManager.shared.showTooltip(clip: clip, index: currentIndex, total: clips.count)")
ad = ad.replace("ClipboardManager.shared.setPasteboard(content: text)", "ClipboardManager.shared.setPasteboard(content: clip.content)")
with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

# 2. TooltipManager.swift
with open('Sources/multipaste/TooltipManager.swift', 'r') as f:
    tm = f.read()
tm = tm.replace("let view = TooltipView(content: content, index: index, total: total)", "let view = TooltipView(clip: clip, index: index, total: total)")
with open('Sources/multipaste/TooltipManager.swift', 'w') as f:
    f.write(tm)

# 3. TooltipView.swift (rewrite entirely to be clean)
tv_content = """import SwiftUI

struct TooltipView: View {
    let clip: Clip
    let index: Int
    let total: Int
    
    var body: some View {
        HStack {
            Text("\\(index + 1)/\\(total)")
                .font(.caption)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.gray.opacity(0.3)))
            
            if clip.type == "image", let data = clip.blob, let nsImage = NSImage(data: data) {
                Image(nsImage: nsImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 150)
            } else if clip.type == "file" {
                HStack {
                    Image(systemName: "doc")
                    Text(clip.content)
                        .lineLimit(3)
                }
            } else {
                Text(clip.content)
                    .lineLimit(3)
            }
        }
        .padding()
        .background(VisualEffectView(material: .menu, blendingMode: .behindWindow))
        .cornerRadius(8)
        .shadow(radius: 4)
    }
}
"""
with open('Sources/multipaste/TooltipView.swift', 'w') as f:
    f.write(tv_content)
