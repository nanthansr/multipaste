---
file: Sources/multipaste/TooltipManager.swift
size: 3289
mtime: 2026-05-21T02:30:14.906770Z
sha256: 1be67c85986f9647237c6c2f0a512dfa5276a4cc9450a6e7cfd9efefd71e9601
---

# Sources/multipaste/TooltipManager.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import SwiftUI

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
        
        let error = AXUIElementCopyAttribute
```
