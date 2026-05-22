import os
import AppKit
import SwiftUI

private let log = Logger(subsystem: "com.local.multipaste", category: "TooltipManager")
class TooltipManager {
    static let shared = TooltipManager()
    
    private var window: NSWindow?
    
    private init() {}
    
    func showTooltip(content: String, index: Int, total: Int) {
        if window == nil {
            let panel = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 250, height: 80),
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
        
        let view = TooltipView(content: content, index: index, total: total)
        window?.contentView = NSHostingView(rootView: view)
        
        positionWindow()
        window?.orderFront(nil)
    }
    
    func hideTooltip() {
        window?.orderOut(nil)
    }
    
    private func positionWindow() {
        guard let window = window else { return }
        
        // Try to get caret position via Accessibility
        var position = getCaretPosition()
        
        if position == nil {
            // Fallback to mouse cursor
            let mouseLoc = NSEvent.mouseLocation
            position = CGPoint(x: mouseLoc.x + 15, y: mouseLoc.y - 15)
        }
        
        if let pos = position {
            // Adjust for window size
            let windowFrame = NSRect(x: pos.x, y: pos.y - window.frame.height, width: window.frame.width, height: window.frame.height)
            window.setFrame(windowFrame, display: true)
        }
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
                
                // Convert screen coordinates to AppKit coordinates
                if let screen = NSScreen.main {
                    let y = screen.frame.height - rect.origin.y
                    return CGPoint(x: rect.origin.x, y: y)
                }
            }
        }
        return nil
    }
}
