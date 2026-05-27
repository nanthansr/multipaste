import AppKit
import ServiceManagement

class SettingsWindowController: NSWindowController {

    static let shared = SettingsWindowController()
    private var hudCountLabel: NSTextField?
    
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
        
        let loginButton = NSButton(checkboxWithTitle: "Launch at login", target: self, action: #selector(toggleLogin(_:)))
        loginButton.frame = NSRect(x: 20, y: 220, width: 300, height: 24)
        if #available(macOS 13.0, *) {
            loginButton.state = SMAppService.mainApp.status == .enabled ? .on : .off
        }
        loginButton.isEnabled = true
        generalView.addSubview(loginButton)

        let telemetryButton = NSButton(checkboxWithTitle: "Enable anonymous analytics", target: self, action: #selector(toggleTelemetry(_:)))
        telemetryButton.frame = NSRect(x: 20, y: 190, width: 300, height: 24)
        telemetryButton.state = UserDefaults.standard.bool(forKey: "multipaste.settings.telemetryEnabled") ? .on : .off
        generalView.addSubview(telemetryButton)

        // HUD tile count
        let savedCount = UserDefaults.standard.integer(forKey: "multipaste.hudTileCount")
        let initialCount = savedCount > 0 ? max(3, min(7, savedCount)) : 6

        let hudLabel = NSTextField(labelWithString: "Radial HUD tiles:")
        hudLabel.frame = NSRect(x: 20, y: 155, width: 150, height: 24)
        generalView.addSubview(hudLabel)

        let hudStepper = NSStepper()
        hudStepper.frame = NSRect(x: 178, y: 157, width: 40, height: 20)
        hudStepper.minValue = 3
        hudStepper.maxValue = 7
        hudStepper.increment = 1
        hudStepper.intValue = Int32(initialCount)
        hudStepper.valueWraps = false
        hudStepper.target = self
        hudStepper.action = #selector(hudTileCountChanged(_:))
        generalView.addSubview(hudStepper)

        let countLabel = NSTextField(labelWithString: "\(initialCount)")
        countLabel.frame = NSRect(x: 224, y: 155, width: 24, height: 24)
        generalView.addSubview(countLabel)
        hudCountLabel = countLabel

        let rangeLabel = NSTextField(labelWithString: "(3 – 7)")
        rangeLabel.frame = NSRect(x: 252, y: 155, width: 70, height: 24)
        rangeLabel.textColor = .tertiaryLabelColor
        rangeLabel.font = NSFont.systemFont(ofSize: 11)
        generalView.addSubview(rangeLabel)

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
    
    @objc func toggleTelemetry(_ sender: NSButton) {
        UserDefaults.standard.set(sender.state == .on, forKey: "multipaste.settings.telemetryEnabled")
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
                // Log silently
            }
        }
    }
    
    @objc func hudTileCountChanged(_ sender: NSStepper) {
        let val = Int(sender.intValue)
        UserDefaults.standard.set(val, forKey: "multipaste.hudTileCount")
        hudCountLabel?.stringValue = "\(val)"
    }

    func showWindow() {
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
