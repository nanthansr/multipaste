import os
import AppKit
import SwiftUI

private let log = Logger(subsystem: "com.nanthansr.multipaste", category: "TooltipManager")
class TooltipManager {
    static let shared = TooltipManager()
    
    private var window: NSWindow?
    
    private init() {}
    
    func showTooltip(clip: Clip, index: Int, total: Int) {
        if window == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 200),
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
            window = panel
        }
        
        let view = TooltipView(clip: clip, index: index, total: total)
        window?.contentView = NSHostingView(rootView: view)

        // Size the panel to fit the content type before positioning.
        if clip.type == "image", let data = clip.blob, let img = NSImage(data: data), img.size.height > 0 {
            let aspect = img.size.width / img.size.height
            let targetWidth: CGFloat = 480
            let targetHeight = min(400, max(200, targetWidth / aspect))
            window?.setContentSize(NSSize(width: targetWidth, height: targetHeight))
        } else {
            window?.setContentSize(NSSize(width: 380, height: 200))
        }

        positionWindow()
        window?.alphaValue = 0
        window?.orderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.12
            self.window?.animator().alphaValue = 1
        }
    }

    func hideTooltip() {
        guard let w = window else { return }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.08
            w.animator().alphaValue = 0
        }, completionHandler: {
            w.orderOut(nil)
        })
    }
    
    private func positionWindow() {
        guard let window = window else { return }

        var position = getCaretPosition()

        if position == nil {
            let mouseLoc = NSEvent.mouseLocation
            position = CGPoint(x: mouseLoc.x + 12, y: mouseLoc.y + 12)
        }

        guard let pos = position else { return }

        let targetScreen = NSScreen.screens.first(where: { $0.frame.contains(pos) })
            ?? NSScreen.main
            ?? NSScreen.screens[0]
        let screenFrame = targetScreen.visibleFrame
        let windowSize = window.frame.size

        // Prefer showing tooltip below the caret; flip above if it would clip the bottom edge
        var y = pos.y - windowSize.height - 4
        if y < screenFrame.minY {
            y = pos.y + 4
        }

        var x = pos.x
        x = min(x, screenFrame.maxX - windowSize.width)
        x = max(x, screenFrame.minX)
        y = min(y, screenFrame.maxY - windowSize.height)
        y = max(y, screenFrame.minY)

        let finalFrame = NSRect(x: x, y: y, width: windowSize.width, height: windowSize.height)
        fileLog("tooltip frame: \(finalFrame)")
        window.setFrame(finalFrame, display: true)
    }
    
    private func getCaretPosition() -> CGPoint? {
        let systemWideElement = AXUIElementCreateSystemWide()
        var focusedElement: CFTypeRef?
        
        let error = AXUIElementCopyAttributeValue(systemWideElement, kAXFocusedUIElementAttribute as CFString, &focusedElement)
        guard error == .success, let element = focusedElement else { return nil }
        
        let axElement = element as! AXUIElement
        
        var selectedRangeValue: CFTypeRef?
        if AXUIElementCopyAttributeValue(axElement, kAXSelectedTextRangeAttribute as CFString, &selectedRangeValue) == .success {
            let rangeValue = selectedRangeValue as! AXValue
            
            var range = CFRange()
            AXValueGetValue(rangeValue, .cfRange, &range)
            
            var boundsValue: CFTypeRef?
            if AXUIElementCopyParameterizedAttributeValue(axElement, kAXBoundsForRangeParameterizedAttribute as CFString, rangeValue, &boundsValue) == .success {
                let boundsAXValue = boundsValue as! AXValue
                
                var rect = CGRect.zero
                AXValueGetValue(boundsAXValue, .cgRect, &rect)
                guard rect != .zero else { return nil }

                // AX origin is top-left of primary screen, Y increases downward.
                // AppKit origin is bottom-left of primary screen (screens[0]), Y increases upward.
                let primaryScreenHeight = NSScreen.screens[0].frame.height
                let y = primaryScreenHeight - rect.origin.y
                let point = CGPoint(x: rect.origin.x, y: y)
                fileLog("AX caret: rect=\(rect) → appkit=\(point)")
                // Some apps return a non-zero but off-screen rect; reject those.
                guard NSScreen.screens.contains(where: { $0.frame.contains(point) }) else {
                    fileLog("AX caret outside all screens, falling back to mouse")
                    return nil
                }
                return point
            }
        }
        return nil
    }
}
