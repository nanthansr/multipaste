# Multipaste - handoff document
Last updated: 2026-05-26

## Current state
Multipaste has a fully functional clipboard engine (Cycle & Drop, FIFO mode, Radial HUD). We are currently executing a production-readiness audit to fix deployment blockers, security/privacy issues, and code quality before launch.

## What works
- Core CGEventTap interception (Cmd+Shift+V)
- Clipboard polling and echo-suppression
- Tooltip UI and Radial HUD
- Local SQLite database storage

## What's broken / Needs fixing
- `LicenseManager.swift` is being restored and integrated.
- Free/Pro gating is missing (history cap, image/file capture, FIFO mode).
- Telemetry (PostHog, Supabase) needs a consent toggle.
- Debug logging writes sensitive data to `/tmp/multipaste_debug.log`.
- FIFO mode has a stale pasteboard restoration bug.

## What's next
1. Finish P0 critical fixes (LicenseManager, Pro gating, history cap)
2. Finish P1 security/privacy fixes (Debug log, telemetry consent, FIFO bug, missing menu items)
3. Finish P2 code quality (API keys to Config.swift, schema migration fix)

## Open decisions needed from user
- Sentry/Bugsnag crash reporting integration (deferred to post-launch)
- XCTest setup for Swift package (deferred to post-launch)

## Build and run commands
```bash
bash scripts/build-app.sh
open Multipaste.app
```
**Important:** Never use `swift run` or run the raw binary directly, as the Accessibility permission grant is tied to the code signature of the built `.app` bundle.

## Hard rules
1. **Do not rewrite the CGEventTap + echo-suppression core.** (`HotkeyManager.swift` and `ClipboardManager.swift`).
2. **Never use `2>&1`** in shell commands.
3. Keep stdout and stderr separate.

## File map
- `Sources/multipaste/multipaste.swift` - Entry point
- `Sources/multipaste/AppDelegate.swift` - Menu bar, lifecycle, hotkey delegate
- `Sources/multipaste/ClipboardManager.swift` - Pasteboard polling
- `Sources/multipaste/DatabaseManager.swift` - SQLite storage
- `Sources/multipaste/HotkeyManager.swift` - Global CGEventTap
- `Sources/multipaste/TooltipManager.swift` / `TooltipView.swift` - UI
- `Sources/multipaste/RadialHUDManager.swift` / `RadialHUDView.swift` - HUD UI
- `Sources/multipaste/LicenseManager.swift` - Gumroad licensing (Pro)
- `Sources/multipaste/SettingsWindowController.swift` - Settings UI
