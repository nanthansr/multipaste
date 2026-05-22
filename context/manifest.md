# Multipaste context manifest

Generated from the repository so agents can read a small, structured summary before opening source files.

- Repository root: /Users/nanthansr/Personal_Projects/multipaste
- Files indexed: 10

## Index

| Path | Kind | Lines | Hash | Summary |
| --- | --- | ---: | --- | --- |
| MULTIPASTE_PLAN.md | markdown | 61 | 2f23997c1c6a | Product and implementation plan for the multipaste clipboard buffer and future roadmap. |
| Package.swift | swift | 28 | ae0f4c63c5ff | Swift Package Manager manifest for the multipaste app and its context generator. |
| Sources/contextbrain/main.swift | swift | 276 | 376097157a51 | Repository scanner that generates the context manifest for agent consumption. |
| Sources/multipaste/AppDelegate.swift | swift | 171 | abd6350e2363 | Background app delegate that coordinates launch, menu bar state, clipboard polling, hotkey handling, FIFO mode, and paste injection. |
| Sources/multipaste/ClipboardManager.swift | swift | 68 | 9db334ea0823 | Clipboard polling layer that watches NSPasteboard, filters synthetic pastes, and records new text clips. |
| Sources/multipaste/DatabaseManager.swift | swift | 78 | 2ba5497d8b90 | SQLite-backed storage manager that provisions the local clip database and reads recent clipboard history. |
| Sources/multipaste/HotkeyManager.swift | swift | 98 | cbe3dd155b49 | Global event-tap hotkey manager that intercepts Cmd+Shift+V cycling and Cmd+V FIFO handling. |
| Sources/multipaste/TooltipManager.swift | swift | 91 | 1be67c85986f | Floating tooltip controller that positions the clip preview near the caret or mouse cursor. |
| Sources/multipaste/TooltipView.swift | swift | 44 | 14cdc75bcbec | SwiftUI tooltip view and AppKit visual-effect wrapper used for the translucent clip preview. |
| Sources/multipaste/multipaste.swift | swift | 15 | 39626e4c87e9 | Application entry point that boots the background AppKit app in accessory mode. |

## File details

### MULTIPASTE_PLAN.md

- Kind: markdown
- Lines: 61
- Hash: 2f23997c1c6adfe1d25bbca74ebadd0f78c5691af7cc4912675ac922084d21f5
- Summary: Product and implementation plan for the multipaste clipboard buffer and future roadmap.
- Symbols: Multipaste: The "Cycle & Drop" Clipboard Buffer, 1. Product Vision & Philosophy, 2. Technical Stack, 3. Current Implementation Status (What has been built), Completed Components:, Tested & Fixed Bugs:, 4. Future Roadmap & Ideas, Phase 1: Polish & UX, Phase 2: The ML Portfolio Angle (Optional), Phase 3: Go-to-Market

### Package.swift

- Kind: swift
- Lines: 28
- Hash: ae0f4c63c5ffff33d3371d9f81b622180c533fc5ab3611eca60750ff03c3fb3b
- Summary: Swift Package Manager manifest for the multipaste app and its context generator.
- Imports: PackageDescription

### Sources/contextbrain/main.swift

- Kind: swift
- Lines: 276
- Hash: 376097157a51d207aeda8fd2a6d5602627a34320f7c8cc531e77bb7aeb4a839c
- Summary: Repository scanner that generates the context manifest for agent consumption.
- Imports: Foundation, CryptoKit
- Symbols: FileRecord, ContextBrain, Configuration, main, printHelp, scanRepository, shouldSkipDirectory, shouldIncludeFile, kindForFile, extractSwiftImports, extractSymbols, summaryForFile

### Sources/multipaste/AppDelegate.swift

- Kind: swift
- Lines: 171
- Hash: abd6350e2363f8d35afe6b75b4d95c008344b3b3de0b3b8763aba0aff784a023
- Summary: Background app delegate that coordinates launch, menu bar state, clipboard polling, hotkey handling, FIFO mode, and paste injection.
- Imports: AppKit, ApplicationServices
- Symbols: AppDelegate, applicationDidFinishLaunching, setupMenuBar, applicationWillTerminate, hotkeyManagerDidTriggerCycle, hotkeyManagerDidReleaseModifiers, hotkeyManagerDidTriggerPaste, injectPaste, simulateCmdV

### Sources/multipaste/ClipboardManager.swift

- Kind: swift
- Lines: 68
- Hash: 9db334ea0823f7460a94bc661d73e5936c0bca083a2cfab3c3e1a8b282536478
- Summary: Clipboard polling layer that watches NSPasteboard, filters synthetic pastes, and records new text clips.
- Imports: AppKit, Foundation
- Symbols: ClipboardManager, startPolling, stopPolling, checkPasteboard, setPasteboard

### Sources/multipaste/DatabaseManager.swift

- Kind: swift
- Lines: 78
- Hash: 2ba5497d8b903a126d321ede97fda7d18dce00ecac62a8c456d8b1a0dc292a6c
- Summary: SQLite-backed storage manager that provisions the local clip database and reads recent clipboard history.
- Imports: Foundation, SQLite
- Symbols: DatabaseManager, setupDatabase, insertClip, fetchRecentClips

### Sources/multipaste/HotkeyManager.swift

- Kind: swift
- Lines: 98
- Hash: cbe3dd155b495fd14cb38d15e63a75bc77887e824641ab654289abcc20494aea
- Summary: Global event-tap hotkey manager that intercepts Cmd+Shift+V cycling and Cmd+V FIFO handling.
- Imports: AppKit, ApplicationServices, Foundation
- Symbols: HotkeyManagerDelegate, HotkeyManager, hotkeyManagerDidTriggerCycle, hotkeyManagerDidReleaseModifiers, hotkeyManagerDidTriggerPaste, start, stop, handleEvent

### Sources/multipaste/TooltipManager.swift

- Kind: swift
- Lines: 91
- Hash: 1be67c85986f9647237c6c2f0a512dfa5276a4cc9450a6e7cfd9efefd71e9601
- Summary: Floating tooltip controller that positions the clip preview near the caret or mouse cursor.
- Imports: AppKit, SwiftUI
- Symbols: TooltipManager, showTooltip, hideTooltip, positionWindow, getCaretPosition

### Sources/multipaste/TooltipView.swift

- Kind: swift
- Lines: 44
- Hash: 14cdc75bcbeca97e5dc2cceeb94a6a6f8b0d129244447b613251ec5db125e55b
- Summary: SwiftUI tooltip view and AppKit visual-effect wrapper used for the translucent clip preview.
- Imports: SwiftUI
- Symbols: TooltipView, VisualEffectView, makeNSView, updateNSView

### Sources/multipaste/multipaste.swift

- Kind: swift
- Lines: 15
- Hash: 39626e4c87e9af894d9ae2b4702584550c9234a814a2acb8301f1715aba8560a
- Summary: Application entry point that boots the background AppKit app in accessory mode.
- Imports: AppKit, Darwin
- Symbols: multipaste, main
