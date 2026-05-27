import os

import Foundation
func fileLog(_ msg: String) {
    if let appSupportURL = try? FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true) {
        let appDirectory = appSupportURL.appendingPathComponent("multipaste", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
        let url = appDirectory.appendingPathComponent("debug.log")
        let txt = "\(Date()): \(msg)\n"
        
        if !FileManager.default.fileExists(atPath: url.path) {
            FileManager.default.createFile(atPath: url.path, contents: nil, attributes: [.posixPermissions: 0o600])
        }
        
        if let handle = try? FileHandle(forWritingTo: url) {
            handle.seekToEndOfFile()
            if let data = txt.data(using: .utf8) { handle.write(data) }
            handle.closeFile()
        } else {
            try? txt.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

import AppKit
import ApplicationServices
import PostHog

private let log = Logger(subsystem: "com.nanthansr.multipaste", category: "AppDelegate")
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
            fileLog("Accessibility permissions not granted. Please enable them in System Settings.")
        }
        
        if UserDefaults.standard.object(forKey: "multipaste.settings.telemetryEnabled") == nil {
            UserDefaults.standard.set(true, forKey: "multipaste.settings.telemetryEnabled")
        }
        
        if UserDefaults.standard.bool(forKey: "multipaste.settings.telemetryEnabled") {
            let phConfig = PostHogConfig(projectToken: Config.posthogToken, host: "https://us.i.posthog.com")
            PostHogSDK.shared.setup(phConfig)
            PostHogSDK.shared.capture("app_launched")
            if accessEnabled {
                PostHogSDK.shared.capture("accessibility_granted")
            }
            SupabaseManager.shared.recordLaunch(isLicensed: true)
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
        
        fileLog("Multipaste is running in the background.")
    }
    
    @objc private func handleNewClip(_ notification: Notification) {
        guard isFIFOModeEnabled, let text = notification.object as? String else { return }
        fifoQueue.append(text)
        fileLog("Added to FIFO queue. Queue size: \(self.fifoQueue.count)")
    }
    
    private 
    func checkAccessibility() {
        if AXIsProcessTrusted() { return }
        
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Multipaste needs Accessibility access to intercept your clipboard hotkeys (Cmd+Shift+V) globally.\n\nPlease click 'Open System Settings', enable Multipaste, and wait for this dialog to disappear."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Quit")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
            
            // Poll until granted
            Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
                if AXIsProcessTrusted() {
                    timer.invalidate()
                    let success = NSAlert()
                    success.messageText = "Permission Granted!"
                    success.informativeText = "Multipaste is now ready to use."
                    success.runModal()
                }
            }
        } else {
            NSApplication.shared.terminate(nil)
        }
    }

    func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "MP"
        }
        
        let menu = NSMenu()
        
        let licenseStateStr: String
        switch LicenseManager.shared.state {
        case .free: licenseStateStr = "Upgrade to Pro..."
        case .trial(let days): licenseStateStr = "License: Trial (\(days) days remaining)"
        case .pro: licenseStateStr = "License: Pro"
        case .expired: licenseStateStr = "Upgrade to Pro..."
        }
        
        menu.addItem(NSMenuItem(title: licenseStateStr, action: #selector(showLicenseUI), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        let fifoItem = NSMenuItem(title: isFIFOModeEnabled ? "Disable FIFO Mode" : "Enable FIFO Mode", action: #selector(toggleFIFO), keyEquivalent: "")
        menu.addItem(fifoItem)
        
        menu.addItem(NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ","))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc private func showLicenseUI() {
        // Simple alert for now, could be a proper window later
        let alert = NSAlert()
        alert.messageText = "Enter License Key"
        alert.informativeText = "Please enter your Gumroad license key:"
        alert.alertStyle = .informational
        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        alert.accessoryView = input
        alert.addButton(withTitle: "Activate")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            let key = input.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { return }
            
            Task {
                do {
                    try await LicenseManager.shared.activate(key: key)
                    DispatchQueue.main.async {
                        let successAlert = NSAlert()
                        successAlert.messageText = "Activated!"
                        successAlert.informativeText = "Thank you for supporting Multipaste."
                        successAlert.runModal()
                        self.setupMenuBar() // Refresh menu
                    }
                } catch {
                    DispatchQueue.main.async {
                        let errorAlert = NSAlert()
                        errorAlert.messageText = "Activation Failed"
                        errorAlert.informativeText = error.localizedDescription
                        errorAlert.runModal()
                    }
                }
            }
        }
    }
    
    @objc private func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear History"
        alert.informativeText = "Are you sure you want to delete all saved clips? This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            DatabaseManager.shared.clearAll()
        }
    }
    
    @objc private func showSettings() {
        SettingsWindowController.shared.showWindow()
    }
    
    @objc private func toggleFIFO(_ sender: NSMenuItem) {
        if !LicenseManager.shared.isProUnlocked && !isFIFOModeEnabled {
            let alert = NSAlert()
            alert.messageText = "Upgrade to Pro"
            alert.informativeText = "FIFO Sequential Paste is a Pro feature."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
            return
        }

        isFIFOModeEnabled.toggle()
        sender.title = isFIFOModeEnabled ? "Disable FIFO Mode" : "Enable FIFO Mode"
        
        if isFIFOModeEnabled {
            originalPasteboardContent = NSPasteboard.general.string(forType: .string)
            fifoQueue = []
            fileLog("FIFO Mode Enabled")
        } else {
            fifoQueue = []
            fileLog("FIFO Mode Disabled")
            if let original = originalPasteboardContent {
                ClipboardManager.shared.setPasteboard(content: original)
            }
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
        if UserDefaults.standard.bool(forKey: "multipaste.settings.telemetryEnabled") {
            if !UserDefaults.standard.bool(forKey: "multipaste.firedFirstHotkey") {
                UserDefaults.standard.set(true, forKey: "multipaste.firedFirstHotkey")
                PostHogSDK.shared.capture("first_hotkey_triggered")
            }
        }
            clips = DatabaseManager.shared.fetchRecentClips(limit: 999)
            if clips.isEmpty { return }
            currentIndex = 0
        } else {
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
        if UserDefaults.standard.bool(forKey: "multipaste.settings.telemetryEnabled") {
            if !UserDefaults.standard.bool(forKey: "multipaste.firedFirstPaste") {
                UserDefaults.standard.set(true, forKey: "multipaste.firedFirstPaste")
                PostHogSDK.shared.capture("first_paste_completed", properties: ["mode": "cycle"])
            }
            PostHogSDK.shared.capture("clip_pasted", properties: ["mode": "cycle"])
            SupabaseManager.shared.incrementUsage(mode: "cycle")
        }
        injectPaste(clip: clip)
    }

    func hotkeyManagerDidOpenRadialHUD() {
        let savedCount = UserDefaults.standard.integer(forKey: "multipaste.hudTileCount")
        let tileCount = savedCount > 0 ? max(3, min(7, savedCount)) : 6
        let clips = DatabaseManager.shared.fetchRecentClips(limit: tileCount)
        guard !clips.isEmpty else { return }
        let mouseLoc = NSEvent.mouseLocation
        RadialHUDManager.shared.show(clips: clips, at: mouseLoc) { [weak self] clip in
            RadialHUDManager.shared.hide()
            HotkeyManager.shared.radialHUDDidDismiss()
            if UserDefaults.standard.bool(forKey: "multipaste.settings.telemetryEnabled") {
                PostHogSDK.shared.capture("clip_pasted", properties: ["mode": "radialHUD"])
                SupabaseManager.shared.incrementUsage(mode: "hud")
            }
            self?.injectPaste(clip: clip)
        }
    }

    func hotkeyManagerDidDismissRadialHUD() {
        RadialHUDManager.shared.hide()
    }

    func hotkeyManagerDidTriggerPaste() -> Bool {
        guard isFIFOModeEnabled, !fifoQueue.isEmpty else { return false }
        
        let text = fifoQueue.removeFirst()
        fileLog("FIFO pasting: remaining: \(self.fifoQueue.count)")
        
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

    
    private func injectPaste(clip: Clip) {
        ClipboardManager.shared.isPasting = true
        
        // Save current pasteboard to restore later
        let currentPasteboardContent = NSPasteboard.general.string(forType: .string)
        
        // Set new content based on type
        NSPasteboard.general.clearContents()
        if clip.type == "image", let data = clip.blob {
            NSPasteboard.general.setData(data, forType: .tiff)
        } else if clip.type == "file" {
            let paths = clip.content.components(separatedBy: "\n")
            let urls = paths.map { URL(fileURLWithPath: $0) }
            NSPasteboard.general.writeObjects(urls as [NSURL])
        } else {
            NSPasteboard.general.setString(clip.content, forType: .string)
        }
        
        // Wait a tiny bit for the OS to register the pasteboard change
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.simulateCmdV()
            
            // Increased delay to 0.4s to prevent target app from reading too early
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
