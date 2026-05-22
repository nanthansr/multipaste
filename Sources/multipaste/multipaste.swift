import AppKit
import Darwin

@main
struct multipaste {
    static func main() {
        setbuf(stdout, nil)
        let app = NSApplication.shared
        let delegate = AppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // Run as background app (no dock icon)
        app.run()
    }
}
