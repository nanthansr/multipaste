import Foundation
import Security

enum LicenseState {
    case free
    case trial(daysRemaining: Int)
    case pro
    case expired
}

class LicenseManager {
    static let shared = LicenseManager()

    private let permalink = "multipaste"
    private let keychainService = "com.nanthansr.multipaste.licenseKey"
    private let firstLaunchKey = "multipaste.firstLaunchDate"
    private let firstLaunchKeychainService = "com.nanthansr.multipaste.firstLaunchDate"

    private(set) var state: LicenseState = .free

    var isProUnlocked: Bool {
        if case .pro = state { return true }
        if case .trial = state { return true }
        return false
    }

    private init() {
        refresh()
    }

    func refresh() {
        if getLicenseKey() != nil {
            state = .pro
            return
        }

        let defaults = UserDefaults.standard
        let now = Date()
        
        var firstLaunchDate: Date?
        
        // Try keychain first (tamper resistant)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: firstLaunchKeychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        if SecItemCopyMatching(query as CFDictionary, &dataTypeRef) == errSecSuccess, let data = dataTypeRef as? Data, let dateString = String(data: data, encoding: .utf8), let interval = TimeInterval(dateString) {
            firstLaunchDate = Date(timeIntervalSince1970: interval)
            defaults.set(firstLaunchDate, forKey: firstLaunchKey)
        } else if let stored = defaults.object(forKey: firstLaunchKey) as? Date {
            firstLaunchDate = stored
            // Backup to keychain
            let data = String(stored.timeIntervalSince1970).data(using: .utf8)!
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: firstLaunchKeychainService,
                kSecValueData as String: data
            ]
            SecItemAdd(addQuery as CFDictionary, nil)
        } else {
            firstLaunchDate = now
            defaults.set(now, forKey: firstLaunchKey)
            let data = String(now.timeIntervalSince1970).data(using: .utf8)!
            let addQuery: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: firstLaunchKeychainService,
                kSecValueData as String: data
            ]
            SecItemAdd(addQuery as CFDictionary, nil)
        }
        
        guard let start = firstLaunchDate else {
            state = .expired
            return
        }
        
        let elapsed = Calendar.current.dateComponents([.day], from: start, to: now).day ?? 0
        if elapsed < 14 {
            state = .trial(daysRemaining: max(0, 14 - elapsed))
        } else {
            state = .expired
        }
    }

    func activate(key: String) async throws {
        let url = URL(string: "https://api.gumroad.com/v2/licenses/verify")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let bodyString = "product_permalink=\(permalink)&license_key=\(key)"
        request.httpBody = bodyString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpRes = response as? HTTPURLResponse, httpRes.statusCode == 200 else {
            throw NSError(domain: "LicenseError", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid response from activation server."])
        }

        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let success = json["success"] as? Bool, success == true else {
            throw NSError(domain: "LicenseError", code: 2,
                          userInfo: [NSLocalizedDescriptionKey: "Invalid license key."])
        }

        saveLicenseKey(key)
        refresh()
    }

    private func saveLicenseKey(_ key: String) {
        let data = key.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecValueData as String: data
        ]
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func getLicenseKey() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
}
