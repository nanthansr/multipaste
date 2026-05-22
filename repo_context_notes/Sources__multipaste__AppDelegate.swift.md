---
file: Sources/multipaste/AppDelegate.swift
size: 6140
mtime: 2026-05-21T02:31:18.913322Z
sha256: abd6350e2363f8d35afe6b75b4d95c008344b3b3de0b3b8763aba0aff784a023
---

# Sources/multipaste/AppDelegate.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import ApplicationServices

class AppDelegate: NSObject, NSApplicationDelegate, HotkeyManagerDelegate {
    
    private var clips: [(id: Int64, content: String, type: String, timestamp: Date)] = []
    private var currentIndex: Int = -1
    
    private var statusItem: NSStatusItem!
    private var isFIFOModeEnabled = false
    private var fifoQueue: [String] = []
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check Accessibility Permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            print("Accessibility permissions not granted. Please enable them in System Settings.")
        }
        
        setupMenuBar()
        
        // Initialize Database
        _ = DatabaseManager.shared
        
        // Start Clipboard Polling
        ClipboardManager.shared.startPolling()
        
        // Start Hotkey Interception
        HotkeyManager.shared.delegate = self
        HotkeyManager.shared.start()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNewClip(_:)), name: NSNotification.Name("NewClipAdded"), object: nil)
        
        print("Multipaste is running in the background.")
    }
    
    @objc private func handleNewClip(_ notification: Notification) {
        guard isFIFOModeEnabled, let text = notification.object as? String else { return }
        fifoQueue.append(text)
        print("Added to FIFO queue. Queue size: \(fifoQueue.count)")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "MP"
        }
        
        let menu = NSMenu()
        
        let fifoItem = NSMenuItem(title: "Enable FIFO Mode", action: #selector(toggleFIFO
```
