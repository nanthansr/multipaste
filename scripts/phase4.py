with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()

# Add Settings and License menu items
menu_add = """
        let licenseItem = NSMenuItem(title: LicenseManager.shared.isProUnlocked ? "License: Pro" : "Upgrade to Pro...", action: #selector(showLicense), keyEquivalent: "")
        menu.addItem(licenseItem)
        
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(showSettings), keyEquivalent: ",")
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())
"""
if "Settings..." not in ad:
    ad = ad.replace("menu.addItem(NSMenuItem.separator())\n        let clearItem", menu_add + "        let clearItem")

actions_add = """
    @objc func showSettings() {
        SettingsWindowController.shared.showWindow()
    }
    
    @objc func showLicense() {
        // Implement in Phase 5
    }
"""
if "func showSettings" not in ad:
    ad = ad.replace("func clearHistory() {", actions_add + "\n    @objc func clearHistory() {")

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

