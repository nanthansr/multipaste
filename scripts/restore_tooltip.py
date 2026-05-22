import re

# Add VisualEffectView back
tv_add = """
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
"""
with open('Sources/multipaste/TooltipView.swift', 'a') as f:
    f.write(tv_add)

# Fix AppDelegate clip in toggleFIFO / triggerPaste
with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()
ad = ad.replace("ClipboardManager.shared.setPasteboard(content: clip.content)", "ClipboardManager.shared.setPasteboard(content: text)")
with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

