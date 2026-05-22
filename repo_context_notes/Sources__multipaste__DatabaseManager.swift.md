---
file: Sources/multipaste/DatabaseManager.swift
size: 2936
mtime: 2026-05-21T11:14:50.660433Z
sha256: 2ba5497d8b903a126d321ede97fda7d18dce00ecac62a8c456d8b1a0dc292a6c
---

# Sources/multipaste/DatabaseManager.swift

**Summary:** import Foundation

## Preview

```
import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()
    
    private var db: Connection?
    
    private let clips = Table("clips")
    private let id = Expression<Int64>("id")
    private let content = Expression<String>("content")
    private let type = Expression<String>("type")
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
            
            try db?.run(clips.create(ifNotExists: true) { t in
                t.column(id, primaryKey: .autoincrement)
                t.column(content)
                t.column(type)
                t.column(timestamp)
            })
            print("Database initialized at \(dbURL.path)")
        } catch {
            print("Failed to initialize database: \(error)")
        }
    }
    
    func insertClip(content text: String, type clipType: String = "text") {
        guard let db = db else { return }
        do {
            // Check if the last clip is the same to avoid duplicates
            if let lastClip = try db.pluck(clips.order(timestamp.desc).limit(1)) {
                if lastClip[content] == text {
                    print("Skipping duplicate clip: \(text.prefix(20))...")
                    return
                } else
```
