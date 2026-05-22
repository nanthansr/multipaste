import Cocoa
import os

class ExclusionManager {
    static let shared = ExclusionManager()
    
    private let log = Logger(subsystem: "com.local.multipaste", category: "ExclusionManager")
    
    var exclusions: Set<String> {
        get {
            if let saved = UserDefaults.standard.array(forKey: "multipaste.settings.exclusions") as? [String] {
                return Set(saved)
            }
            return defaultExclusions
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "multipaste.settings.exclusions")
        }
    }
    
    private let defaultExclusions: Set<String> = [
        "com.agilebits.onepassword7",
        "com.agilebits.onepassword-osx",
        "com.bitwarden.desktop",
        "com.lastpass.lastpassmacdesktop",
        "com.apple.keychainaccess",
        "md.obsidian"
    ]
    
    func isExcluded(_ bundleID: String) -> Bool {
        return exclusions.contains(bundleID)
    }
}
