import AppKit
import SwiftUI

class RadialHUDManager {
    static let shared = RadialHUDManager()
    private var window: NSPanel?
    private init() {}

    func show(clips: [Clip], at center: CGPoint, onSelect: @escaping (Clip) -> Void) {
        hide()

        let size: CGFloat = 600
        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: size, height: size),
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        panel.backgroundColor = .clear
        panel.hasShadow = false
        panel.isOpaque = false

        let view = RadialHUDView(clips: clips, onSelect: onSelect)
        panel.contentView = NSHostingView(rootView: view)

        // Center the panel on the mouse cursor, clamped to the screen
        let targetScreen = NSScreen.screens.first(where: { $0.frame.contains(center) })
            ?? NSScreen.main ?? NSScreen.screens[0]
        let sf = targetScreen.visibleFrame
        var x = center.x - size / 2
        var y = center.y - size / 2
        x = min(max(x, sf.minX), sf.maxX - size)
        y = min(max(y, sf.minY), sf.maxY - size)
        panel.setFrameOrigin(CGPoint(x: x, y: y))

        window = panel
        panel.orderFront(nil)
    }

    func hide() {
        window?.orderOut(nil)
        window = nil
    }
}
