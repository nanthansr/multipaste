# Multipaste - Claude Code session startup

Read this file first. Then read `MULTIPASTE_V1_SPEC.md` for the full product spec.

## Current state

6 phases built (via OpenCode + Gemini). Development moved to Claude Code in May 2026. The app is functional - Cycle & Drop works, tooltip renders, Accessibility permission persists across rebuilds.

## Build and run

```bash
bash scripts/build-app.sh   # builds, signs with 'Multipaste Dev' cert, creates Multipaste.app
open Multipaste.app          # launch
```

**Never use `swift run` or run the raw `.build/release/multipaste` binary for testing** - those binaries have a different code identity and won't match the Accessibility permission grant.

## Local dev signing

The app is signed with a self-signed `Multipaste Dev` certificate (in login keychain). This gives a stable designated requirement (`identifier "com.local.multipaste" and certificate leaf = H"a60fcbf8..."`) that survives rebuilds, so the macOS Accessibility permission persists.

If you're on a fresh machine or the cert is missing:
1. Keychain Access → Certificate Assistant → Create a Certificate → Name: `Multipaste Dev`, Type: Code Signing → Always Trust
2. `tccutil reset Accessibility com.local.multipaste` to clear stale TCC entry
3. Rebuild, launch, grant once

Phase 6 (distribution) uses a real Apple Developer ID - already stubbed in `scripts/build-app.sh`.

## Debug log

The app writes to `/tmp/multipaste_debug.log`. Key entries to look for:
- `Event tap started.` - Accessibility trusted, hotkeys active
- `Failed to create event tap` - Accessibility not granted; check TCC

## Delegation convention

- **Claude** - reasoning, architecture, complex logic
- **`agy -p "<task>"`** - trivial tasks: file summaries, structure reads, mechanical find/replace, stripping `print()` spam (Gemini 3.5 Flash via Antigravity, Google AI Pro auth, no API key)
- **`opencode run "<task>" --model opencode-go/deepseek-v4-flash`** - fallback when agy is quota-constrained
- **Opus** - only for genuinely hard problems

## Hard rules (from AGENTS.md)

1. Do not rewrite the `CGEventTap` + echo-suppression core. `HotkeyManager.swift` and the `isPasting`/`lastInjectedText` guards in `ClipboardManager.swift` are tested and working. Extend, do not replace.
2. Never use `2>&1` in shell commands.
3. Work phase by phase. Complete all acceptance criteria before moving to the next phase.
4. Ask the user for items listed in Section 7 ("Open decisions") of the spec before implementing Phases 0, 5, or 6.

## Source files

- `Sources/multipaste/multipaste.swift` - entry point
- `Sources/multipaste/AppDelegate.swift` - menu bar, cycle/paste logic, hotkey delegate
- `Sources/multipaste/ClipboardManager.swift` - 0.5s pasteboard polling, echo-suppression
- `Sources/multipaste/DatabaseManager.swift` - SQLite via SQLite.swift
- `Sources/multipaste/HotkeyManager.swift` - global CGEventTap
- `Sources/multipaste/TooltipManager.swift` - caret-positioned floating panel
- `Sources/multipaste/TooltipView.swift` - SwiftUI tooltip content
- `Sources/multipaste/ExclusionManager.swift` - app exclusion list
- `Sources/multipaste/LicenseManager.swift` - Gumroad license verification
- `Sources/multipaste/SettingsWindowController.swift` - settings UI

## Known issues (pre-existing, not yet fixed)

- Duplicate `blob` column warning on DB init (non-blocking schema migration quirk)
- Debug `print()` spam throughout codebase (delegate removal to agy)
- FIFO mode: stale pasteboard after queue drains
- Phase 0 tasks (bundle ID placeholder `com.YOURNAME.multipaste`, proper code signing for distribution) still pending
