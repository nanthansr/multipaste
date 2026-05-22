import os
import AppKit
import ApplicationServices

private let log = Logger(subsystem: "com.local.multipaste", category: "AppDelegate")
class AppDelegate: NSObject, NSApplicationDelegate, HotkeyManagerDelegate {
    
    private var clips: [Clip] = []
    private var currentIndex: Int = -1
    
    private var statusItem: NSStatusItem!
    
    private var isFIFOModeEnabled = false
    private var originalPasteboardContent: String?

    private var fifoQueue: [String] = []
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check Accessibility Permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !accessEnabled {
            log.debug("Accessibility permissions not granted. Please enable them in System Settings.")
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
        
        log.debug("Multipaste is running in the background.")
    }
    
    @objc private func handleNewClip(_ notification: Notification) {
        guard isFIFOModeEnabled, let text = notification.object as? String else { return }
        fifoQueue.append(text)
        log.debug("Added to FIFO queue. Queue size: \(self.fifoQueue.count)")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "MP"
        }
        
        let menu = NSMenu()
        
        let fifoItem = NSMenuItem(title: "Enable FIFO Mode", action: #selector(toggleFIFO), keyEquivalent: "")
        menu.addItem(fifoItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func toggleFIFO(_ sender: NSMenuItem) {
        isFIFOModeEnabled.toggle()
        sender.title = isFIFOModeEnabled ? "Disable FIFO Mode" : "Enable FIFO Mode"
        
        if isFIFOModeEnabled {
            // Initialize FIFO queue with recent clips or start fresh
            fifoQueue = []
            log.debug("FIFO Mode Enabled")
        } else {
            fifoQueue = []
            log.debug("FIFO Mode Disabled")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        ClipboardManager.shared.stopPolling()
        HotkeyManager.shared.stop()
    }
    
    // MARK: - HotkeyManagerDelegate
    
    
    func hotkeyManagerDidTriggerReverseCycle() {
        guard !clips.isEmpty else { return }
        if currentIndex == -1 { currentIndex = 0 }
        currentIndex = (currentIndex - 1 + clips.count) % clips.count
        
        let clip = clips[currentIndex]
        TooltipManager.shared.showTooltip(clip: clip, index: currentIndex, total: clips.count)
    }

    func hotkeyManagerDidTriggerCycle() {
        if currentIndex == -1 {
            // First cycle, fetch recent clips
            clips = DatabaseManager.shared.fetchRecentClips(limit: 20)
            if clips.isEmpty { return }
            currentIndex = 0
        } else {
            // Move to next clip
            currentIndex = (currentIndex + 1) % clips.count
        }
        
        let clip = clips[currentIndex]
        TooltipManager.shared.showTooltip(clip: clip, index: currentIndex, total: clips.count)
    }
    
    func hotkeyManagerDidReleaseModifiers() {
        guard currentIndex >= 0 && currentIndex < clips.count else { return }
        
        let clip = clips[currentIndex]
        
        // Hide tooltip
        TooltipManager.shared.hideTooltip()
        
        // Reset state
        currentIndex = -1
        clips = []
        
        // Inject paste
        injectPaste(content: clip.content)
    }
    
    
    func hotkeyManagerDidTriggerPaste() -> Bool {
        guard isFIFOModeEnabled, !fifoQueue.isEmpty else { return false }
        
        if fifoQueue.count == 1 { // Last item to dequeue soon
             originalPasteboardContent = NSPasteboard.general.string(forType: .string)
        }
        
        let text = fifoQueue.removeFirst()
        log.debug("FIFO pasting: \(text). Remaining: \(self.fifoQueue.count)")
        
        ClipboardManager.shared.isPasting = true
        ClipboardManager.shared.setPasteboard(content: text)
        
        if fifoQueue.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if let original = self.originalPasteboardContent {
                    ClipboardManager.shared.setPasteboard(content: original)
                }
            }
        }
        
        return true
    }

    
    private func injectPaste(content: String) {
        ClipboardManager.shared.isPasting = true
        
        // Save current pasteboard to restore later
        let currentPasteboardContent = NSPasteboard.general.string(forType: .string)
        
        // Set new content
        ClipboardManager.shared.setPasteboard(content: content)
        
        // Wait a tiny bit for the OS to register the pasteboard change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.simulateCmdV()
            
            // Restore original pasteboard content after paste
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let original = currentPasteboardContent {
                    ClipboardManager.shared.setPasteboard(content: original)
                }
                ClipboardManager.shared.isPasting = false
            }
        }
    }
    
    private func simulateCmdV() {
        let vKeyCode: CGKeyCode = 9
        
        guard let source = CGEventSource(stateID: .hidSystemState) else { return }
        
        let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: true)
        cmdDown?.flags = .maskCommand
        
        let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: vKeyCode, keyDown: false)
        cmdUp?.flags = .maskCommand
        
        cmdDown?.post(tap: .cghidEventTap)
        cmdUp?.post(tap: .cghidEventTap)
    }
}
