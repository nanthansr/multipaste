with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()

license_menu = """
        let licenseTitle: String
        switch LicenseManager.shared.state {
        case .pro: licenseTitle = "License: Pro"
        case .trial(let days): licenseTitle = "Pro Trial: \\(days) days left"
        case .free, .expired: licenseTitle = "Upgrade to Pro..."
        }
        let licenseItem = NSMenuItem(title: licenseTitle, action: #selector(showLicense), keyEquivalent: "")
"""

ad = ad.replace(
    'let licenseItem = NSMenuItem(title: LicenseManager.shared.isProUnlocked ? "License: Pro" : "Upgrade to Pro...", action: #selector(showLicense), keyEquivalent: "")',
    license_menu
)

license_action = """
    @objc func showLicense() {
        let alert = NSAlert()
        alert.messageText = "Activate Pro License"
        alert.informativeText = "Enter your Gumroad license key:"
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
                        successAlert.messageText = "License Activated"
                        successAlert.informativeText = "Thank you for upgrading to Pro!"
                        successAlert.runModal()
                        self.setupMenuBar() // refresh menu
                    }
                } catch {
                    DispatchQueue.main.async {
                        let errAlert = NSAlert()
                        errAlert.messageText = "Activation Failed"
                        errAlert.informativeText = error.localizedDescription
                        errAlert.alertStyle = .critical
                        errAlert.runModal()
                    }
                }
            }
        }
    }
"""

import re
ad = re.sub(r'@objc func showLicense\(\) \{.*?\}', license_action, ad, flags=re.DOTALL)

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

