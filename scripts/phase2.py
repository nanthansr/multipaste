import re

# 1. DatabaseManager.swift
with open('Sources/multipaste/DatabaseManager.swift', 'r') as f:
    db = f.read()

# Update Clip struct
db = db.replace(
"""struct Clip: Identifiable {
    let id: Int64
    let content: String
    let timestamp: Date
    let type: String
}""",
"""struct Clip: Identifiable {
    let id: Int64
    let content: String
    let timestamp: Date
    let type: String
    let blob: Data?
}"""
)

# Add column
if "let blobColumn = Expression<Data?>(\"blob\")" not in db:
    db = db.replace("let type = Expression<String>(\"type\")", "let type = Expression<String>(\"type\")\n    let blobColumn = Expression<Data?>(\"blob\")")

# Migration
migration = """
        do {
            try db?.run("ALTER TABLE clips ADD COLUMN blob BLOB")
        } catch {
            log.debug("Column blob may already exist: \\(error)")
        }
"""
if "ALTER TABLE clips" not in db:
    db = db.replace('try db?.run(clips.create(ifNotExists: true) { t in', migration + '\n        try db?.run(clips.create(ifNotExists: true) { t in')

# Fetch mapping
db = db.replace('type: row[type]\n            )', 'type: row[type],\n                blob: row[blobColumn]\n            )')

# Insert image
insert_img = """
    func insertImageClip(data: Data) {
        guard let db = db else { return }
        do {
            let insert = clips.insert(content <- "Image", timestamp <- Date(), type <- "image", blobColumn <- data)
            try db.run(insert)
            pruneIfNeeded(cap: LicenseManager.shared.isProUnlocked ? Int.max : 50)
        } catch {
            log.error("Failed to insert image: \\(error)")
        }
    }
"""
if "func insertImageClip" not in db:
    db = db.replace('func insertClip(content: String, type: String = "text") {', insert_img + '\n    func insertClip(content: String, type: String = "text") {')

# 2. ClipboardManager.swift
with open('Sources/multipaste/ClipboardManager.swift', 'r') as f:
    cm = f.read()

capture = """
        if LicenseManager.shared.isProUnlocked,
           let imageData = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: NSPasteboard.PasteboardType("public.png")) {
            DatabaseManager.shared.insertImageClip(data: imageData)
            NotificationCenter.default.post(name: NSNotification.Name("NewClipAdded"), object: "Image")
            return
        }
        
        if LicenseManager.shared.isProUnlocked,
           let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
           !fileURLs.isEmpty {
            let paths = fileURLs.map { $0.path }.joined(separator: "\\n")
            DatabaseManager.shared.insertClip(content: paths, type: "file")
            NotificationCenter.default.post(name: NSNotification.Name("NewClipAdded"), object: paths)
            return
        }
"""
if "pasteboard.data(forType: .tiff)" not in cm:
    cm = cm.replace('if let text = pasteboard.string(forType: .string) {', capture + '\n        if let text = pasteboard.string(forType: .string) {')

# 3. TooltipManager.swift
with open('Sources/multipaste/TooltipManager.swift', 'r') as f:
    tm = f.read()
tm = tm.replace('func showTooltip(content: String, index: Int, total: Int)', 'func showTooltip(clip: Clip, index: Int, total: Int)')
tm = tm.replace('let tooltipView = TooltipView(content: content, index: index, total: total)', 'let tooltipView = TooltipView(clip: clip, index: index, total: total)')
if "import Foundation" not in tm and "struct Clip" not in tm:
    pass # we might not need to import anything if it's in the same module, but they share the module space

# 4. AppDelegate.swift updates for TooltipManager call and injectPaste
with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()
ad = ad.replace('TooltipManager.shared.showTooltip(content: clips[currentIndex].content, index: currentIndex, total: clips.count)', 'TooltipManager.shared.showTooltip(clip: clips[currentIndex], index: currentIndex, total: clips.count)')
ad = ad.replace('TooltipManager.shared.showTooltip(content: clips[0].content, index: 0, total: clips.count)', 'TooltipManager.shared.showTooltip(clip: clips[0], index: 0, total: clips.count)')

inject = """
        let clip = clips[currentIndex]
        if clip.type == "image", let data = clip.blob {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setData(data, forType: .tiff)
        } else if clip.type == "file" {
            let paths = clip.content.components(separatedBy: "\\n")
            let urls = paths.map { URL(fileURLWithPath: $0) }
            NSPasteboard.general.clearContents()
            NSPasteboard.general.writeObjects(urls as [NSURL])
        } else {
            ClipboardManager.shared.setPasteboard(content: clip.content)
        }
"""
if 'let clip = clips[currentIndex]' not in ad:
    # replace text injection
    ad = re.sub(r'ClipboardManager\.shared\.setPasteboard\(content: clips\[currentIndex\]\.content\)', inject, ad)

with open('Sources/multipaste/DatabaseManager.swift', 'w') as f: f.write(db)
with open('Sources/multipaste/ClipboardManager.swift', 'w') as f: f.write(cm)
with open('Sources/multipaste/TooltipManager.swift', 'w') as f: f.write(tm)
with open('Sources/multipaste/AppDelegate.swift', 'w') as f: f.write(ad)
