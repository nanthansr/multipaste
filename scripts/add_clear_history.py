with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    content = f.read()

menu_code = """
        menu.addItem(NSMenuItem.separator())
        let clearItem = NSMenuItem(title: "Clear History", action: #selector(clearHistory), keyEquivalent: "")
        menu.addItem(clearItem)
"""
if "Clear History" not in content:
    content = content.replace("let quitItem = NSMenuItem(title: \"Quit\", action: #selector(NSApplication.terminate(_:)), keyEquivalent: \"q\")", menu_code + "\n        let quitItem = NSMenuItem(title: \"Quit\", action: #selector(NSApplication.terminate(_:)), keyEquivalent: \"q\")")

action_code = """
    @objc func clearHistory() {
        let alert = NSAlert()
        alert.messageText = "Clear Clipboard History?"
        alert.informativeText = "This cannot be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        
        if alert.runModal() == .alertFirstButtonReturn {
            DatabaseManager.shared.clearAll()
        }
    }
"""
if "func clearHistory" not in content:
    content = content.replace("    @objc func toggleFIFO(_ sender: NSMenuItem) {", action_code + "\n    @objc func toggleFIFO(_ sender: NSMenuItem) {")

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(content)
