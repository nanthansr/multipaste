import os
import Foundation

private let log = Logger(subsystem: "com.local.multipaste", category: "LicenseManager")
class LicenseManager {
    static let shared = LicenseManager()
    
    // Stub implementation for Phase 1-4.
    var isProUnlocked: Bool {
        return false
    }
}
