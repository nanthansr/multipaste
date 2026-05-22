import re

with open('Sources/multipaste/DatabaseManager.swift', 'r') as f:
    db = f.read()

# Add struct Clip
clip_struct = """
struct Clip: Identifiable {
    let id: Int64
    let content: String
    let timestamp: Date
    let type: String
    let blob: Data?
}
"""
if "struct Clip" not in db:
    db = db.replace('class DatabaseManager {', clip_struct + '\nclass DatabaseManager {')

# Rewrite fetchRecentClips to return [Clip]
new_fetch = """
    func fetchRecentClips(limit: Int = 50) -> [Clip] {
        guard let db = db else { return [] }
        var result: [Clip] = []
        do {
            for row in try db.prepare(clips.order(timestamp.desc).limit(limit)) {
                result.append(Clip(id: row[id], content: row[content], timestamp: row[timestamp], type: row[type], blob: row[blobColumn]))
            }
        } catch {
            log.error("Failed to fetch clips: \\(error)")
        }
        return result
    }
"""
db = re.sub(r'func fetchRecentClips.*?return result\n    \}', new_fetch, db, flags=re.DOTALL)

# Add pruneIfNeeded and clearAll since they might have been lost
prune = """
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
            log.error("Pruning failed: \\(error)")
        }
    }
    
    func clearAll() {
        guard let db = db else { return }
        try? db.run(clips.delete())
    }
"""
if "func pruneIfNeeded" not in db:
    db = db.replace("func fetchRecentClips", prune + "\n    func fetchRecentClips")

# Update insertClip to prune
if "pruneIfNeeded" not in db.split("func insertClip")[1].split("func")[0]:
    db = db.replace('log.debug("Inserted clip:', 'pruneIfNeeded(cap: LicenseManager.shared.isProUnlocked ? Int.max : 50)\n            log.debug("Inserted clip:')

# Add insertImageClip
insert_img = """
    func insertImageClip(data: Data) {
        guard let db = db else { return }
        do {
            let insert = clips.insert(self.content <- "Image", self.timestamp <- Date(), self.type <- "image", self.blobColumn <- data)
            try db.run(insert)
            pruneIfNeeded(cap: LicenseManager.shared.isProUnlocked ? Int.max : 50)
        } catch {
            log.error("Failed to insert image: \\(error)")
        }
    }
"""
if "func insertImageClip" not in db:
    db = db.replace("func insertClip", insert_img + "\n    func insertClip")

with open('Sources/multipaste/DatabaseManager.swift', 'w') as f:
    f.write(db)

# Now fix AppDelegate to match Clip usage
with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()

# fetchRecentClips returns [Clip] now
if "let text = clip.content" not in ad:
    ad = ad.replace("let text = clips[currentIndex].content", "let text = clips[currentIndex].content")
    ad = ad.replace("func toggleFIFO", "func toggleFIFO")

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

# Fix TooltipView
with open('Sources/multipaste/TooltipView.swift', 'r') as f:
    tv = f.read()
tv = tv.replace("let content: String", "let clip: Clip")
tv = tv.replace("Text(content)", "Text(clip.content)")
with open('Sources/multipaste/TooltipView.swift', 'w') as f:
    f.write(tv)
