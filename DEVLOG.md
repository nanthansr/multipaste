# Multipaste devlog

## 2026-05-24 - Phase 7: Tooltip UX polish + Radial HUD

### What changed

**Tooltip positioning fix (7.1)**
- Added screen-bounds validity check to `getCaretPosition()` in [TooltipManager.swift](Sources/multipaste/TooltipManager.swift)
- If the AX caret rect converts to a point outside all screens (some apps return a nonsensical non-zero rect), the code now falls back to mouse location instead of letting the tooltip clamp to the bottom-left corner
- Added `fileLog` debug line logging the raw AX rect and converted AppKit point - visible in `/tmp/multipaste_debug.log`

**Image preview sizing (7.2)**
- For image clips, `showTooltip()` now computes the image's aspect ratio and resizes the panel up to 480x400 before positioning
- Text/file clips keep the default 380x200 panel
- `TooltipView` image uses `.frame(maxWidth: .infinity, maxHeight: .infinity)` so it fills the panel

**Counter badge (7.3)**
- Badge hidden when `total <= 1` (an `if total > 1` guard in the overlay)

**Radial HUD (7.4)**
New interaction mode triggered by holding Cmd+Shift for 300ms without pressing V:
- `HotkeyManager.swift` - timer fires `hotkeyManagerDidOpenRadialHUD()` on 300ms hold; V press cancels the timer and enters cycle mode as usual; modifier release dismisses the HUD
- New `RadialHUDManager.swift` - manages the 600x600 transparent NSPanel centered on the cursor
- New `RadialHUDView.swift` - SwiftUI polar layout (up to 6 clips in a ring, radius 160pt); hover scales tile 1.3x and shows a 200x200 preview card; click fires onSelect to paste and dismiss
- `AppDelegate.swift` implements the two new delegate methods; `injectPaste()` is reused for the HUD paste path

**Tooltip aesthetics (7.5)**
- Material changed from `.menu` to `.popover` (lighter frosted glass)
- Corner radius 12, subtle 1pt stroke border, stronger shadow (radius 16, y-offset 6)
- NSPanel now fade-animates in (120ms) and out (80ms) via `NSAnimationContext`

---

## 2026-05-21 - Session 1: Accessibility fix + base tooltip

### What was built
Core engine in 6 phases using OpenCode + Gemini 3.1 Pro. Development moved to Claude Code.

### Accessibility re-prompt bug (fixed)
Every launch re-prompted for Accessibility because the bundle was only ad-hoc linker-signed. macOS TCC keys the grant to the code identity (designated requirement). Ad-hoc signing ties the DR to `cdhash` which changes on every rebuild, so macOS sees a new app.

**Fix:**
- Created self-signed `Multipaste Dev` certificate in Keychain Access (Code Signing, trusted)
- Added `codesign --force --deep --sign "Multipaste Dev"` to `scripts/build-app.sh`
- Ran `tccutil reset Accessibility com.local.multipaste` to clear the stale grant, then re-granted once
- DR is now `identifier "com.local.multipaste" and certificate leaf = H"..."` - stable across rebuilds

**Rule:** always launch `Multipaste.app` (not `swift run` or the raw binary) - those have a different identity and won't match the grant.

### Tooltip fixes
- `positionWindow()` rewrote with screen detection, flip-above-if-off-bottom logic, and min/max clamping
- Panel sized 380x200, badge moved to top-right overlay, lineLimit 6

### Delegation setup
- `agy -p "..."` (Google Antigravity CLI, Gemini 3.5 Flash via Google AI Pro) confirmed working
- OpenCode Go config fixed (`prompt` → `template` key)
- Convention: Claude does reasoning; trivial/mechanical tasks go to `agy`

---

## Known issues / backlog
- FIFO stale pasteboard after queue drains
- Debug `print()` spam throughout codebase
- Duplicate `blob` column SQLite migration warning (non-blocking)
- Phase 0 items: bundle ID placeholder `com.YOURNAME.multipaste`, proper Apple Developer ID for distribution
- Privacy: ignores `org.nspasteboard.ConcealedType`, stores passwords in plaintext
