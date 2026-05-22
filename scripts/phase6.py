import re

with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()

onboarding = """
    func checkAccessibility() {
        if AXIsProcessTrusted() { return }
        
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Multipaste needs Accessibility access to intercept your clipboard hotkeys (Cmd+Shift+V) globally.\\n\\nPlease click 'Open System Settings', enable Multipaste, and wait for this dialog to disappear."
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
"""

if "func checkAccessibility()" not in ad:
    ad = ad.replace("func applicationDidFinishLaunching(_ aNotification: Notification) {", "func applicationDidFinishLaunching(_ aNotification: Notification) {\n        checkAccessibility()")
    ad = ad.replace("func setupMenuBar() {", onboarding + "\n    func setupMenuBar() {")

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)
