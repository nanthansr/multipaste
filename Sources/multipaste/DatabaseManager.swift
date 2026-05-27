import os
import Foundation
import SQLite

private let log = Logger(subsystem: "com.nanthansr.multipaste", category: "DatabaseManager")

struct Clip: Identifiable {
    let id: Int64
    let content: String
    let timestamp: Date
    let type: String
    let blob: Data?
}

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: Connection?
    
    private let clips = Table("clips")
    private let id = Expression<Int64>("id")
    private let content = Expression<String>("content")
    private let type = Expression<String>("type")
    let blobColumn = Expression<Data?>("blob")
    private let timestamp = Expression<Date>("timestamp")
    
    private init() {
        setupDatabase()
    }
    
    private func setupDatabase() {
        do {
            let fileManager = FileManager.default
            let appSupportURL = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let appDirectory = appSupportURL.appendingPathComponent("multipaste", isDirectory: true)
            
            if !fileManager.fileExists(atPath: appDirectory.path) {
                try fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true, attributes: nil)
            }
            
            let dbURL = appDirectory.appendingPathComponent("db.sqlite3")
            db = try Connection(dbURL.path)
            
            
        do {
            let columns = try db?.prepare("PRAGMA table_info(clips)").map { $0[1] as? String }
            if !(columns?.contains("blob") ?? false) {
                try db?.run("ALTER TABLE clips ADD COLUMN blob BLOB")
            }
        } catch {
            fileLog("Column blob may already exist: \(error)")
        }

        try db?.run(clips.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(content)
                t.column(type)
                t.column(timestamp)
            })
            fileLog("Database initialized at \(dbURL.path)")
        } catch {
            fileLog("Failed to initialize database: \(error)")
        }
    }
    
    
    func insertImageClip(data: Data) {
        guard let db = db else { return }
        do {
            let insert = clips.insert(self.content <- "Image", self.timestamp <- Date(), self.type <- "image", self.blobColumn <- data)
            try db.run(insert)
            pruneIfNeeded(cap: LicenseManager.shared.isProUnlocked ? Int.max : 50)
        } catch {
            fileLog("Failed to insert image: \(error)")
        }
    }

    func insertClip(content text: String, type clipType: String = "text") {
        guard let db = db else { return }
        do {
            // Check if the last clip is the same to avoid duplicates
            if let lastClip = try db.pluck(clips.order(timestamp.desc).limit(1)) {
                if lastClip[self.content] == text {
                    log.debug("Skipping duplicate clip")
                    return
                } else {
                    log.debug("Last clip was different, proceeding with insert")
                }
            }
            
            let insert = clips.insert(self.content <- text, self.type <- clipType, self.timestamp <- Date())
            try db.run(insert)
            log.info("Inserted new clip of type: \(clipType)")
            let cap = LicenseManager.shared.isProUnlocked ? Int.max : 50
            pruneIfNeeded(cap: cap)
        } catch {
            log.error("Failed to insert clip: \(error.localizedDescription)")
        }
    }
    
    
    
    func pruneIfNeeded(cap: Int) {
        guard let db = db else { return }
        do {
            let total = try db.scalar(clips.count)
            if total > cap {
                let excess = total - cap
                let oldest = clips.order(timestamp.asc).limit(excess)
                try db.run(oldest.delete())
            }
        } catch {
            fileLog("Pruning failed: \(error)")
        }
    }
    
    func clearAll() {
        guard let db = db else { return }
        try? db.run(clips.delete())
    }

    func fetchRecentClips(limit: Int = 50) -> [Clip] {
        guard let db = db else { return [] }
        var result: [Clip] = []
        do {
            for row in try db.prepare(clips.order(timestamp.desc).limit(limit)) {
                result.append(Clip(id: row[id], content: row[content], timestamp: row[timestamp], type: row[type], blob: row[blobColumn]))
            }
        } catch {
            fileLog("Failed to fetch clips: \(error)")
        }
        return result
    }

}
