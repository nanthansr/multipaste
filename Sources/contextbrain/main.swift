import Foundation
import CryptoKit

struct FileRecord {
    let path: String
    let kind: String
    let lineCount: Int
    let hash: String
    let summary: String
    let imports: [String]
    let symbols: [String]
}

@main
struct ContextBrain {
    static func main() {
        do {
            let arguments = CommandLine.arguments.dropFirst()
            let config = try Configuration(arguments: Array(arguments))
            let records = try scanRepository(root: config.rootURL)
            let manifest = renderManifest(root: config.rootURL, records: records)

            if config.dryRun {
                print(manifest)
            } else {
                try write(manifest: manifest, to: config.outputURL)
                print("Wrote context manifest to \(config.outputURL.path)")
            }
        } catch {
            fputs("contextbrain failed: \(error)\n", stderr)
            exit(1)
        }
    }
}

private struct Configuration {
    let rootURL: URL
    let outputURL: URL
    let dryRun: Bool

    init(arguments: [String]) throws {
        var rootPath = FileManager.default.currentDirectoryPath
        var outputPath = "context/manifest.md"
        var dryRun = false

        var index = 0
        while index < arguments.count {
            let argument = arguments[index]
            switch argument {
            case "--root":
                index += 1
                guard index < arguments.count else {
                    throw NSError(domain: "ContextBrain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing value for --root"])
                }
                rootPath = arguments[index]
            case "--output":
                index += 1
                guard index < arguments.count else {
                    throw NSError(domain: "ContextBrain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Missing value for --output"])
                }
                outputPath = arguments[index]
            case "--dry-run":
                dryRun = true
            case "--help", "-h":
                Self.printHelp()
                exit(0)
            default:
                throw NSError(domain: "ContextBrain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown argument: \(argument)"])
            }
            index += 1
        }

        self.rootURL = URL(fileURLWithPath: rootPath).standardizedFileURL
        self.outputURL = URL(fileURLWithPath: outputPath, relativeTo: rootURL).standardizedFileURL
        self.dryRun = dryRun
    }

    private static func printHelp() {
        print("Usage: swift run contextbrain [--root PATH] [--output PATH] [--dry-run]")
    }
}

private func scanRepository(root: URL) throws -> [FileRecord] {
    let fileManager = FileManager.default
    let enumerator = fileManager.enumerator(at: root, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])

    var records: [FileRecord] = []

    while let item = enumerator?.nextObject() as? URL {
        let resourceValues = try item.resourceValues(forKeys: [.isDirectoryKey])
        if resourceValues.isDirectory == true {
            if shouldSkipDirectory(item, root: root) {
                enumerator?.skipDescendants()
            }
            continue
        }

        guard shouldIncludeFile(item, root: root) else { continue }

        let data = try Data(contentsOf: item)
        guard let text = String(data: data, encoding: .utf8) else { continue }
        let relativePath = item.path.replacingOccurrences(of: root.path + "/", with: "")

        let kind = kindForFile(at: item)
        let lineCount = text.split(separator: "\n", omittingEmptySubsequences: false).count
        let hash = SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
        let imports = extractSwiftImports(from: text)
        let symbols = extractSymbols(from: text, kind: kind)
        let summary = summaryForFile(path: relativePath, kind: kind, text: text, imports: imports, symbols: symbols)

        records.append(
            FileRecord(
                path: relativePath,
                kind: kind,
                lineCount: lineCount,
                hash: hash,
                summary: summary,
                imports: imports,
                symbols: symbols
            )
        )
    }

    return records.sorted { $0.path < $1.path }
}

private func shouldSkipDirectory(_ url: URL, root: URL) -> Bool {
    let excludedNames = Set([".git", ".build", ".swiftpm", "DerivedData", "context"])
    let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
    return excludedNames.contains(relative.split(separator: "/").first.map(String.init) ?? "")
}

private func shouldIncludeFile(_ url: URL, root: URL) -> Bool {
    let relative = url.path.replacingOccurrences(of: root.path + "/", with: "")
    if relative == "Package.swift" { return true }
    if relative == "MULTIPASTE_PLAN.md" { return true }
    if relative.hasPrefix("Sources/") {
        return ["swift", "md"].contains(url.pathExtension.lowercased())
    }
    return false
}

private func kindForFile(at url: URL) -> String {
    switch url.pathExtension.lowercased() {
    case "swift":
        return "swift"
    case "md":
        return "markdown"
    default:
        return "other"
    }
}

private func extractSwiftImports(from text: String) -> [String] {
    let pattern = "^\\s*import\\s+([A-Za-z0-9_]+)"
    return matches(pattern: pattern, in: text)
}

private func extractSymbols(from text: String, kind: String) -> [String] {
    switch kind {
    case "swift":
        let typeNames = matches(pattern: "^\\s*(?:final\\s+)?(?:public\\s+|internal\\s+|private\\s+|fileprivate\\s+)?(class|struct|enum|protocol|actor)\\s+([A-Za-z_][A-Za-z0-9_]*)", in: text, captureGroup: 2)
        let functionNames = matches(pattern: "^\\s*(?:public\\s+|internal\\s+|private\\s+|fileprivate\\s+)?(?:static\\s+|class\\s+)?func\\s+([A-Za-z_][A-Za-z0-9_]*)", in: text)
        return Array((typeNames + functionNames).prefix(12))
    case "markdown":
        return matches(pattern: "^#{1,6}\\s+(.+)$", in: text)
    default:
        return []
    }
}

private func summaryForFile(path: String, kind: String, text: String, imports: [String], symbols: [String]) -> String {
    let overrides: [String: String] = [
        "Package.swift": "Swift Package Manager manifest for the multipaste app and its context generator.",
        "MULTIPASTE_PLAN.md": "Product and implementation plan for the multipaste clipboard buffer and future roadmap.",
        "Sources/multipaste/AppDelegate.swift": "Background app delegate that coordinates launch, menu bar state, clipboard polling, hotkey handling, FIFO mode, and paste injection.",
        "Sources/multipaste/ClipboardManager.swift": "Clipboard polling layer that watches NSPasteboard, filters synthetic pastes, and records new text clips.",
        "Sources/multipaste/DatabaseManager.swift": "SQLite-backed storage manager that provisions the local clip database and reads recent clipboard history.",
        "Sources/multipaste/HotkeyManager.swift": "Global event-tap hotkey manager that intercepts Cmd+Shift+V cycling and Cmd+V FIFO handling.",
        "Sources/multipaste/TooltipManager.swift": "Floating tooltip controller that positions the clip preview near the caret or mouse cursor.",
        "Sources/multipaste/TooltipView.swift": "SwiftUI tooltip view and AppKit visual-effect wrapper used for the translucent clip preview.",
        "Sources/multipaste/multipaste.swift": "Application entry point that boots the background AppKit app in accessory mode.",
        "Sources/contextbrain/main.swift": "Repository scanner that generates the context manifest for agent consumption."
    ]

    if let override = overrides[path] {
        return override
    }

    if kind == "swift" {
        let importSummary = imports.prefix(2).joined(separator: ", ")
        let symbolSummary = symbols.prefix(4).joined(separator: ", ")
        var parts: [String] = []
        if !importSummary.isEmpty {
            parts.append("Imports \(importSummary)")
        }
        if !symbolSummary.isEmpty {
            parts.append("Contains \(symbolSummary)")
        }
        if parts.isEmpty {
            parts.append("Swift source file.")
        }
        return parts.joined(separator: ". ")
    }

    if kind == "markdown" {
        if let heading = symbols.first {
            return "Markdown note centered on \(heading)."
        }
        return "Markdown note."
    }

    return "Source file."
}

private func renderManifest(root: URL, records: [FileRecord]) -> String {
    var lines: [String] = []
    lines.append("# Multipaste context manifest")
    lines.append("")
    lines.append("Generated from the repository so agents can read a small, structured summary before opening source files.")
    lines.append("")
    lines.append("- Repository root: \(root.path)")
    lines.append("- Files indexed: \(records.count)")
    lines.append("")
    lines.append("## Index")
    lines.append("")
    lines.append("| Path | Kind | Lines | Hash | Summary |")
    lines.append("| --- | --- | ---: | --- | --- |")

    for record in records {
        lines.append("| \(record.path) | \(record.kind) | \(record.lineCount) | \(String(record.hash.prefix(12))) | \(escapeTableCell(record.summary)) |")
    }

    lines.append("")
    lines.append("## File details")
    lines.append("")

    for record in records {
        lines.append("### \(record.path)")
        lines.append("")
        lines.append("- Kind: \(record.kind)")
        lines.append("- Lines: \(record.lineCount)")
        lines.append("- Hash: \(record.hash)")
        lines.append("- Summary: \(record.summary)")
        if !record.imports.isEmpty {
            lines.append("- Imports: \(record.imports.joined(separator: ", "))")
        }
        if !record.symbols.isEmpty {
            lines.append("- Symbols: \(record.symbols.joined(separator: ", "))")
        }
        lines.append("")
    }

    return lines.joined(separator: "\n")
}

private func write(manifest: String, to outputURL: URL) throws {
    let directory = outputURL.deletingLastPathComponent()
    try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
    try manifest.write(to: outputURL, atomically: true, encoding: .utf8)
}

private func matches(pattern: String, in text: String, captureGroup: Int = 1) -> [String] {
    guard let regex = try? NSRegularExpression(pattern: pattern, options: [.anchorsMatchLines]) else { return [] }
    let range = NSRange(text.startIndex..., in: text)
    return regex.matches(in: text, options: [], range: range).compactMap { match in
        guard match.numberOfRanges > captureGroup else { return nil }
        let captureRange = match.range(at: captureGroup)
        guard let swiftRange = Range(captureRange, in: text) else { return nil }
        return String(text[swiftRange])
    }
}

private func escapeTableCell(_ value: String) -> String {
    value.replacingOccurrences(of: "|", with: "\\|")
}