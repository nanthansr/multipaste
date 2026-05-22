import AppKit
import ServiceManagement

class SettingsWindowController: NSWindowController {
    
    static let shared = SettingsWindowController()
    
    private init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Multipaste Settings"
        window.center()
        
        super.init(window: window)
        
        let tabView = NSTabView(frame: window.contentView!.bounds)
        tabView.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(tabView)
        
        // General Tab
        let generalTab = NSTabViewItem(identifier: "General")
        generalTab.label = "General"
        let generalView = NSView()
        
        let loginButton = NSButton(checkboxWithTitle: "Launch at login (Pro)", target: self, action: #selector(toggleLogin(_:)))
        loginButton.frame = NSRect(x: 20, y: 220, width: 300, height: 24)
        if #available(macOS 13.0, *) {
            loginButton.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        loginButton.isEnabled = LicenseManager.shared.isProUnlocked
        generalView.addSubview(loginButton)
        
        let proLabel = NSTextField(labelWithString: LicenseManager.shared.isProUnlocked ? "" : "Upgrade to Pro to enable Launch at Login and more.")
        proLabel.frame = NSRect(x: 20, y: 190, width: 360, height: 24)
        proLabel.textColor = .secondaryLabelColor
        generalView.addSubview(proLabel)
        
        generalTab.view = generalView
        tabView.addTabViewItem(generalTab)
        
        // Exclusions Tab
        let exclusionsTab = NSTabViewItem(identifier: "Exclusions")
        exclusionsTab.label = "Exclusions"
        let exclusionsView = NSView()
        let exclusionsLabel = NSTextField(labelWithString: "Excluded Apps (coming soon):")
        exclusionsLabel.frame = NSRect(x: 20, y: 220, width: 360, height: 24)
        exclusionsView.addSubview(exclusionsLabel)
        
        exclusionsTab.view = exclusionsView
        tabView.addTabViewItem(exclusionsTab)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleLogin(_ sender: NSButton) {
        if #available(macOS 13.0, *) {
            do {
                if sender.state == .on {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to toggle login item: \\(error)")
            }
        }
    }
    
    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
