import Foundation
import Supabase

class SupabaseManager {
    static let shared = SupabaseManager()

    private let client = SupabaseClient(
        supabaseURL: Config.supabaseURL,
        supabaseKey: Config.supabaseKey
    )

    private var deviceID: String {
        if let id = UserDefaults.standard.string(forKey: "multipaste.deviceID") { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: "multipaste.deviceID")
        return id
    }

    private init() {}

    func recordLaunch(isLicensed: Bool) {
        let id = deviceID
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
        let os = ProcessInfo.processInfo.operatingSystemVersionString
        let now = ISO8601DateFormatter().string(from: Date())
        Task {
            try? await client.from("users")
                .upsert([
                    "device_id": id,
                    "app_version": version,
                    "os_version": os,
                    "is_licensed": isLicensed ? "true" : "false",
                    "last_seen_at": now
                ], onConflict: "device_id")
                .execute()
        }
    }

    func submitFeedback(_ message: String) {
        let id = deviceID
        Task {
            try? await client.from("feedback")
                .insert(["device_id": id, "message": message])
                .execute()
        }
    }

    func incrementUsage(mode: String) {
        let id = deviceID
        let dateStr = String(ISO8601DateFormatter().string(from: Date()).prefix(10))
        let column = mode == "hud" ? "hud_count" : "cycle_count"
        Task {
            try? await client.from("daily_usage")
                .upsert(["device_id": id, "date": dateStr], onConflict: "device_id,date")
                .execute()
            try? await client.rpc("increment_usage",
                params: ["p_device_id": id, "p_column": column])
                .execute()
        }
    }
}
