import Foundation
import Security

class LicenseManager {
    static let shared = LicenseManager()

    private let permalink = "multipaste" // update to actual Gumroad slug before launch
    private let keychainService = "com.local.multipaste.licenseKey"

    var isUnlocked: Bool {
        getLicenseKey() != nil
    }

    private init() {}

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
