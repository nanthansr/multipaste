# Multipaste v1 - build spec for Gemini

> **What this doc is:** A complete, phase-by-phase engineering spec for turning the Multipaste engine into a shippable, sellable macOS app. Every phase has explicit acceptance criteria. Work through the phases in order - each one gates the next.
>
> **What is already built:** The core engine works and has been stress-tested. Your job is to build the product *around* that engine. Never rewrite the event-tap/echo-suppression core; see the Guardrails section.

---

## 1. Mission and positioning

### The problem

Existing clipboard managers (Paste, Maccy, Raycast) are long-term retrieval tools. They solve "what did I copy last Tuesday?" They force users to break flow - open a UI, search, click, press Enter - for every single paste. This makes sequential pasting (copy 3 things, paste them in order) slow and frustrating.

### What Multipaste is

Multipaste is the **rapid-fire interaction layer for the next 10 seconds**. It lives invisibly alongside long-term managers like Raycast or Maccy. It does two things that no incumbent does:

- **Cycle & Drop:** hold `Cmd+Shift`, tap `V` to cycle through recent clips. A translucent tooltip appears exactly at the text cursor. Release the modifiers to instantly paste. Zero flow break, pure muscle memory.
- **FIFO sequential paste (Pro):** enable FIFO mode, copy items A, B, C in order, then tap `Cmd+V` three times to paste them in order. Eliminates back-and-forth entirely.

### Why this positioning matters right now

macOS 26 Tahoe ships clipboard history built into Spotlight for free. Maccy and Raycast are free. **Do not position Multipaste as "another clipboard history app" - that market just became free.** Position it as the interaction-model upgrade that none of them have. Multipaste is a complement to Spotlight/Maccy, not a replacement.

### Target user

Developers and data-entry workers who repeatedly copy multiple items and paste them in sequence - filling forms, reformatting data, writing code. They copy like a surgeon and paste like one.

---

## 2. Monetization model

### Free vs Pro

| Feature | Free | Pro |
|---|---|---|
| Cycle & Drop (text clips) | Yes | Yes |
| Recent history cap | Last 50 clips | Unlimited |
| Privacy/safety (concealed type, app exclusion) | Yes | Yes |
| Menu bar | Yes | Yes |
| FIFO sequential paste | No | Yes |
| Images + files (capture, cycle, paste) | No | Yes |
| Launch at login | No | Yes |
| Customizable hotkeys | No | Yes (initially; can unlock free later) |
| On-device semantic search | No | Later update |

### Pricing

- **Free tier:** ungated, no trial expiry, distribute freely to maximize adoption and GitHub stars.
- **Pro:** one-time **$17 USD** (not subscription). The indie macOS market strongly prefers one-time over subscriptions; Paste's subscription fatigue is a recurring complaint in 2026 reviews. A $17 lifetime deal is the sweet spot against Pastebot ($13) and Alfred Powerpack ($39).
- **14-day Pro trial:** all Pro features unlocked from first launch; no credit card required. Banner in menu bar during trial ("Pro trial: X days remaining"). After expiry, Pro features lock gracefully.

### Distribution and license keys

Sell direct via **Gumroad** or **Lemon Squeezy** (both handle VAT/tax automatically, no need to register as a tax agent in 40 countries). Do NOT use the Mac App Store - the app uses a global CGEventTap which cannot be sandboxed.

Use **Gumroad's license-key API** for activation:
1. Customer purchases, receives a license key string from Gumroad.
2. On "Activate License" in the app, call `POST https://api.gumroad.com/v2/licenses/verify` with the key and product_permalink.
3. If the response is `{ success: true, ... }`, store the activation in the macOS Keychain (`com.multipaste.license`) with the key and activation timestamp.
4. On subsequent launches, check Keychain only. The app works fully offline after the first activation.
5. On invalid or refunded key, the API returns `{ success: false, ... }`; show an error message.

If Lemon Squeezy is preferred over Gumroad, its license verify endpoint follows the same pattern (`POST https://api.lemonsqueezy.com/v1/licenses/validate`).

**No server to run, no backend to maintain.** All verification is against the payment provider's hosted API, cached locally in Keychain.

### Ask the user before implementing Phase 5
Confirm: Gumroad or Lemon Squeezy? Product permalink/ID? (Required for the API call.)

---

## 3. Current-state audit

The core engine is built and tested. Here is the exact state of each file so you do not need to re-derive it.

### What works

| File | What it does | Status |
|---|---|---|
| `Sources/multipaste/multipaste.swift` | `@main` entry, sets `.accessory` activation policy (no dock icon) | Working |
| `Sources/multipaste/AppDelegate.swift` | Menu bar "MP", accessibility prompt, FIFO toggle, cycle/paste delegates, `injectPaste()` + `simulateCmdV()` | Working |
| `Sources/multipaste/ClipboardManager.swift` | 0.5s timer polls `NSPasteboard`; `isPasting` flag + `lastInjectedText` guard echo-suppression | Working |
| `Sources/multipaste/DatabaseManager.swift` | SQLite.swift at `~/Library/Application Support/multipaste/db.sqlite3`; `insertClip`, `fetchRecentClips`, last-clip dedup | Working |
| `Sources/multipaste/HotkeyManager.swift` | `CGEventTap` at `.cgSessionEventTap`; swallows `Cmd+Shift+V`, intercepts `Cmd+V` in FIFO mode | Working |
| `Sources/multipaste/TooltipManager.swift` | `NSPanel`, AX-API caret position, mouse fallback | Working |
| `Sources/multipaste/TooltipView.swift` | SwiftUI tooltip with `VisualEffectView` | Working |

### Known bugs to fix (required for v1)

1. **Not a `.app` bundle.** The project builds to a raw SPM executable. There is no `Info.plist`, no icon, no codesigning path. Users cannot install it. This is Phase 0.

2. **Privacy violation.** `ClipboardManager.swift:47` captures ALL pasteboard changes including passwords. It ignores `org.nspasteboard.ConcealedType` (the flag password managers set). No app-exclusion list. No history limit. No way to clear history. This is Phase 1 and blocks trust.

3. **Text-only.** `ClipboardManager.swift:47` only reads `NSPasteboard.PasteboardType.string`. Images and files are silently dropped. The `type` column in the DB exists but is always `"text"`. This is Phase 2.

4. **Multi-monitor caret bug.** `TooltipManager.swift:82` uses `NSScreen.main` to convert AX screen coordinates. On multi-monitor setups, the tooltip mispositions by the height of the wrong screen. Fix: use the screen that contains the caret point, not `.main`.

5. **No reverse cycle.** `AppDelegate.swift:90` cycles forward only (`currentIndex + 1 % count`). If the user overshoots the desired clip they have to cycle all the way around. Add a reverse-direction shortcut.

6. **FIFO stale pasteboard.** `AppDelegate.swift:114-131` sets the pasteboard to the FIFO item but never restores the user's original clipboard content after the queue drains. After FIFO empties, hitting `Cmd+V` pastes the last FIFO item indefinitely.

7. **Debug `print()` spam.** All files use `print()` for logging. This pollutes stdout and leaks user clipboard content to any process with Console access. Replace with `os.Logger`.

8. **Scratch files and no git repo.** `check_pb*.swift`, `test_loop.sh`, `test_fifo.sh`, `output.log`, `app.log` are in the project root. No git history. Phase 0.

---

## 4. Phased build plan

Work through phases in order. Do not start the next phase until all acceptance criteria for the current phase are met.

---

### Phase 0 - Repo and bundle hygiene

Goal: the project is a real installable macOS app and a clean git repository. Nothing in this phase changes app behavior.

**Tasks:**

**0a. Initialize git.**
```
git init
git add .
git commit -m "initial commit: working clipboard engine"
```
Add to `.gitignore`:
```
.build/
*.log
check_pb*.swift
test_*.sh
output.log
```
Delete from the repo: `check_pb.swift`, `check_pb2.swift`, `check_pb3.swift`, `check_pb4.swift`, `check_pb5.swift`, `test_loop.sh`, `test_fifo.sh`, `output.log`, `app.log`.

**0b. Replace `print()` with `os.Logger`.**
In every Swift source file, remove all `print(...)` calls. Import `os` and create a module-level logger:
```swift
import os
private let log = Logger(subsystem: "com.YOURNAME.multipaste", category: "ClipboardManager") // adjust category per file
```
Use `log.debug(...)`, `log.info(...)`, `log.error(...)` appropriately. Never log full clipboard contents at `.info` or above - use `.debug` only.

**0c. Create the `.app` bundle structure.**
Write a shell script `scripts/build-app.sh` that:
1. Runs `swift build -c release`
2. Creates `Multipaste.app/Contents/MacOS/` and `Multipaste.app/Contents/Resources/`
3. Copies `.build/release/multipaste` to `Multipaste.app/Contents/MacOS/Multipaste`
4. Writes `Multipaste.app/Contents/Info.plist` with the following keys:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.YOURNAME.multipaste</string>
    <key>CFBundleName</key>
    <string>Multipaste</string>
    <key>CFBundleDisplayName</key>
    <string>Multipaste</string>
    <key>CFBundleExecutable</key>
    <string>Multipaste</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSAccessibilityUsageDescription</key>
    <string>Multipaste needs Accessibility access to read the cursor position and intercept keyboard shortcuts.</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
```

5. Copies an app icon (`AppIcon.icns`) into `Contents/Resources/` if one exists; otherwise skip.

Replace `YOURNAME` with the user's Apple Developer Team name or short identifier. **Ask the user for this before proceeding.**

**0d. Add a placeholder app icon.**
Create a simple 1024x1024 PNG (can be a solid color square with "MP" text) and convert to `AppIcon.icns` using `iconutil`. Commit it. A real icon can be replaced later without code changes.

**Acceptance criteria for Phase 0:**
- Running `./scripts/build-app.sh` produces `Multipaste.app` in the project root.
- Double-clicking `Multipaste.app` launches the app as a menu-bar-only process (no dock icon, no app window). "MP" appears in the menu bar.
- `swift run` and Xcode are no longer required for end-user installation.
- Opening Console.app with `com.YOURNAME.multipaste` as the subsystem filter shows structured log output when the app runs.
- `stdout` is silent (no `print()` output).
- `git status` shows a clean working tree with no scratch files.

---

### Phase 1 - Privacy and safety

Goal: Multipaste must be trustworthy before it can be sold. Privacy is the primary objection a buyer will have.

**Tasks:**

**1a. Respect concealed and transient pasteboard types.**
In `ClipboardManager.swift`, modify `checkPasteboard()` before the `isPasting` guard. After confirming the change count changed, check the pasteboard's current types:

```swift
let types = pasteboard.types ?? []
let skipTypes: [NSPasteboard.PasteboardType] = [
    NSPasteboard.PasteboardType("org.nspasteboard.ConcealedType"),
    NSPasteboard.PasteboardType("org.nspasteboard.TransientType"),
    NSPasteboard.PasteboardType("org.nspasteboard.AutoGeneratedType"),
]
if types.contains(where: { skipTypes.contains($0) }) {
    log.debug("Skipping concealed/transient pasteboard change")
    return
}
```
This single change stops password manager content from ever entering the DB.

**1b. App-exclusion list.**
Add a `ExclusionManager.swift` singleton that maintains a set of bundle IDs whose content should not be captured. Pre-populate with known password managers:

```swift
var defaultExclusions: Set<String> = [
    "com.agilebits.onepassword7",
    "com.agilebits.onepassword-osx",
    "com.bitwarden.desktop",
    "com.lastpass.lastpassmacdesktop",
    "com.apple.keychainaccess",
    "md.obsidian",  // Obsidian Private Notes (remove if user disagrees)
]
```

In `checkPasteboard()`, after the concealed-type check, get the frontmost app bundle ID via:
```swift
if let frontBundleID = NSWorkspace.shared.frontmostApplication?.bundleIdentifier,
   ExclusionManager.shared.isExcluded(frontBundleID) {
    return
}
```

Store the user-configurable exclusion list in `UserDefaults` (or a JSON file in app support). The settings window (Phase 4) will expose it.

**1c. History cap and pruning.**
Add a constant `maxHistoryFree = 50`. In `DatabaseManager.insertClip()`, after a successful insert, count the total rows. If the count exceeds the cap for the current tier, delete the oldest rows:

```swift
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
        log.error("Pruning failed: \(error)")
    }
}
```

Call `pruneIfNeeded(cap: LicenseManager.shared.isProUnlocked ? Int.max : maxHistoryFree)` after every insert. (Implement `LicenseManager` as a stub returning `false` for now; wire it up properly in Phase 5.)

**1d. Clear history action.**
Add a "Clear History" menu item in `AppDelegate.setupMenuBar()`. The action calls `DatabaseManager.shared.clearAll()`:
```swift
func clearAll() {
    guard let db = db else { return }
    try? db.run(clips.delete())
}
```
Show a confirmation dialog before clearing.

**Acceptance criteria for Phase 1:**
- Copy a password from 1Password or Bitwarden. The item does NOT appear when cycling with `Cmd+Shift+V`. Verify by inspecting the SQLite DB directly.
- With an app in the exclusion list as the frontmost app, copies made in that app do not appear in history.
- After copying more than 50 items (free tier), the DB contains exactly 50 rows (the 50 most recent).
- "Clear History" empties the DB and a confirmation dialog precedes it.

---

### Phase 2 - Multi-format clips (Pro)

Goal: capture, store, display, and paste images and files - not just text.

**Tasks:**

**2a. Extend the DB schema.**
Add a migration to `DatabaseManager.setupDatabase()` that adds a `blob` column for binary data (images):
```swift
try db?.run("ALTER TABLE clips ADD COLUMN blob BLOB")
```
Guard with a `do/catch` - if the column already exists SQLite throws, which is safe to ignore. The existing `type` column already exists (`"text"`, `"image"`, `"file"`).

**2b. Extend ClipboardManager to capture images and file URLs.**
After the existing text-capture block in `checkPasteboard()`, add:

```swift
// Image capture (Pro only)
if LicenseManager.shared.isProUnlocked,
   let imageData = pasteboard.data(forType: .tiff) ?? pasteboard.data(forType: NSPasteboard.PasteboardType("public.png")) {
    DatabaseManager.shared.insertImageClip(data: imageData)
}

// File capture (Pro only)
if LicenseManager.shared.isProUnlocked,
   let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self], options: nil) as? [URL],
   !fileURLs.isEmpty {
    let paths = fileURLs.map { $0.path }.joined(separator: "\n")
    DatabaseManager.shared.insertClip(content: paths, type: "file")
}
```

Add `insertImageClip(data: Data)` to `DatabaseManager` that stores the blob in the new column.

**2c. Extend TooltipView to render thumbnails.**
Pass the `type` and optional `imageData: Data?` to `TooltipView`. Render differently per type:
- `"text"`: existing text preview.
- `"image"`: `Image(nsImage: NSImage(data: imageData!))` resized to fit within the tooltip.
- `"file"`: show the filename(s) with an SF Symbol `"doc"` icon.

**2d. Extend injectPaste to paste images and files.**
In `AppDelegate.injectPaste()`, check the clip type:
- `"text"`: existing path (set pasteboard string, synthesize Cmd+V).
- `"image"`: `NSPasteboard.general.setData(imageData, forType: .tiff)` then synthesize Cmd+V.
- `"file"`: write `[NSURL]` objects to the pasteboard then synthesize Cmd+V.

**Acceptance criteria for Phase 2:**
- Copy an image from Safari or Preview. The image thumbnail appears in the tooltip when cycling. Releasing on a TextEdit or Notes document pastes the image inline.
- Copy a file from Finder. The filename appears in the tooltip. Releasing on a Mail compose window attaches the file (or pastes the path in a plain text field).
- Text clips are unaffected.
- On the free tier (no license), image/file clips are not captured.

---

### Phase 3 - Core UX polish

Goal: fix the three showstopper UX issues and make the tooltip feel native.

**Tasks:**

**3a. Fix multi-monitor caret positioning.**
In `TooltipManager.positionWindow()`, after computing `pos`:
```swift
// Find the screen that contains the caret, not just NSScreen.main
let targetScreen = NSScreen.screens.first(where: { $0.frame.contains(pos) }) ?? NSScreen.main!
```
Use `targetScreen.frame` for any coordinate-space calculations. The existing `NSScreen.main` reference at line 82 (`let y = screen.frame.height - rect.origin.y`) in `getCaretPosition()` must also be corrected: replace with the screen whose frame contains `rect.origin`, or use `NSScreen.screens` to find the correct screen.

**3b. Add reverse cycle.**
In `HotkeyManager.handleEvent()`, detect a "reverse" hotkey - recommend `Cmd+Shift+Z` (or make it configurable in Phase 4). Add a second delegate method `hotkeyManagerDidTriggerReverseCycle()`. In `AppDelegate`, implement it to decrement `currentIndex`:
```swift
func hotkeyManagerDidTriggerReverseCycle() {
    guard !clips.isEmpty else { return }
    if currentIndex == -1 { currentIndex = 0 }
    currentIndex = (currentIndex - 1 + clips.count) % clips.count
    TooltipManager.shared.showTooltip(content: clips[currentIndex].content, index: currentIndex, total: clips.count)
}
```
Ask the user to confirm the reverse-cycle hotkey before implementing; `Cmd+Shift+Z` conflicts with system Undo in some apps.

**3c. Harden FIFO mode.**
In `hotkeyManagerDidTriggerPaste()` (called from `AppDelegate`):
1. Before the first item is dequeued, save the current pasteboard string: `let originalContent = NSPasteboard.general.string(forType: .string)`.
2. After the last item is dequeued (i.e. `fifoQueue.isEmpty` after the `removeFirst()`), schedule a restore: 
```swift
DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
    if let original = originalContent {
        ClipboardManager.shared.setPasteboard(content: original)
    }
}
```
3. When FIFO mode is disabled (in `toggleFIFO()`), clear both the queue and the stale pasteboard by restoring whatever was on the clipboard before FIFO started. Store the pre-FIFO content when mode is enabled.

**3d. Redesign the tooltip.**
Update `TooltipView.swift` to match the native macOS appearance:
- Background: `.menu` material (slightly darker than `.popover`, standard for menu-adjacent overlays).
- Font: `Font.system(.body)` for content (not monospaced - this was visually wrong for prose text). Use `.caption` for the index counter.
- Index counter: a small pill `Capsule` background, not bare text.
- Content-type icon: SF Symbol to the left of the content. `"text.quote"` for text, `"photo"` for images, `"doc"` for files.
- Max width: `300` (was `250`; some clips are wider).
- Dark mode: works automatically via `NSVisualEffectView`.
- No explicit `.shadow(...)` call - the `.menu` material provides its own elevation.

**Acceptance criteria for Phase 3:**
- On a dual-monitor setup, the tooltip appears at the caret regardless of which screen the focused app is on.
- Holding `Cmd+Shift` and tapping `V` forward then backward cycles through clips in both directions.
- FIFO mode pastes items A, B, C in exact order; after the queue drains, the clipboard reverts to the content it held before FIFO started; hitting `Cmd+V` again does a normal paste of that original content.
- The tooltip uses the system body font, has a pill index counter with a content-type icon, and looks visually identical in light and dark mode.

---

### Phase 4 - Settings, launch-at-login, customization

Goal: the app is configurable enough for a paying customer.

**Tasks:**

**4a. Build the Settings window.**
Create `SettingsWindowController.swift`. Open it via a "Settings..." menu item in the menu bar. Use a tab view with two tabs:

- **General tab:** toggle FIFO mode default on launch; history cap slider (free tier: locked at 50; Pro: 50–unlimited toggle); "Clear All History" button; launch at login toggle (Pro only).
- **Exclusions tab:** a list of excluded app bundle IDs; add/remove buttons.

Persist all settings in `UserDefaults` with a clear key prefix (`multipaste.settings.*`).

**4b. Customizable hotkeys.**
Replace the hardcoded `vKeyCode: Int64 = 9` and modifier checks in `HotkeyManager` with values read from `UserDefaults`:
```swift
var cycleKeyCode: Int64 { UserDefaults.standard.integer(forKey: "multipaste.settings.cycleKeyCode") != 0
    ? Int64(UserDefaults.standard.integer(forKey: "multipaste.settings.cycleKeyCode"))
    : 9 }
```
Add a hotkey recorder UI in Settings (a simple text field that captures the next key press and displays it is sufficient for v1; use `NSEvent.addLocalMonitorForEvents` while the field is first responder).

**4c. Launch at login (Pro).**
Use `ServiceManagement.SMAppService.mainApp`:
```swift
import ServiceManagement

func setLaunchAtLogin(_ enabled: Bool) {
    if enabled {
        try? SMAppService.mainApp.register()
    } else {
        try? SMAppService.mainApp.unregister()
    }
}
```
Gate this behind `LicenseManager.shared.isProUnlocked`. If the user is on the free tier, show a "Upgrade to Pro" prompt.

**4d. License status in menu.**
Add a "License: Pro" / "License: Trial (X days remaining)" / "Upgrade to Pro..." menu item above the separator.

**Acceptance criteria for Phase 4:**
- "Settings..." opens the settings window. Changes persist after relaunching the app.
- Changing the cycle hotkey in Settings takes effect immediately without relaunch.
- On a Pro/trial license, enabling "Launch at Login" causes the app to appear in System Settings > General > Login Items and launch on next reboot.
- On the free tier, Pro settings are visible but disabled with an "Upgrade to Pro" label.

---

### Phase 5 - Monetization plumbing

Goal: the free/Pro gate is real, the license can be activated and stored, and the trial countdown is accurate.

**Tasks:**

**5a. `LicenseManager.swift`.**
Create a singleton with:
```swift
enum LicenseState {
    case free
    case trial(daysRemaining: Int)
    case pro
    case expired
}

class LicenseManager {
    static let shared = LicenseManager()
    private(set) var state: LicenseState = .free
    var isProUnlocked: Bool { ... }
    func activate(key: String) async throws { ... }
    func refresh() { ... } // called on launch
}
```

**5b. Trial logic.**
On first launch (checked via `UserDefaults`), record `multipaste.firstLaunchDate = Date()`. On every launch, compute days elapsed. If < 14, `state = .trial(daysRemaining: 14 - elapsed)` and `isProUnlocked = true`. If >= 14, `state = .expired` and `isProUnlocked = false`. Do not allow the trial to restart by deleting UserDefaults.

**5c. License activation.**
`activate(key:)` hits the Gumroad API:
```
POST https://api.gumroad.com/v2/licenses/verify
  license_key=<key>
  product_permalink=<your_product_permalink>
```
Confirm the product permalink with the user before hardcoding it. On success (`json["success"] == true`), store the key in the Keychain under `com.YOURNAME.multipaste.licenseKey`. Set `state = .pro`. On failure, throw a descriptive error.

For Keychain storage use `Security.SecItemAdd` / `SecItemCopyMatching` with `kSecClassGenericPassword`.

**5d. Feature gates.**
Replace the stub `LicenseManager.shared.isProUnlocked` checks added in Phases 1-4 with the real implementation. Pro-gated features: FIFO mode capture (`ClipboardManager`), image/file capture (`ClipboardManager`), unlimited history (`DatabaseManager.pruneIfNeeded`), launch-at-login (`AppDelegate`).

**5e. "Enter License Key" UI.**
Add a menu item "Activate Pro License...". Opens a sheet (a small `NSAlert`-style panel is sufficient) with a text field for the key and an "Activate" button. On success, update the menu bar to show "License: Pro".

**Acceptance criteria for Phase 5:**
- On a fresh install (cleared UserDefaults + Keychain), the app enters a 14-day Pro trial. Trial banner shows in the menu. FIFO and image capture work.
- After trial expiry (simulate by backdating `firstLaunchDate` in UserDefaults), Pro features are locked. The menu shows "Upgrade to Pro...".
- Entering a valid Gumroad license key via "Activate Pro License..." unlocks all Pro features permanently. The key persists in Keychain through reboots.
- Entering an invalid or already-used key shows a clear error message.
- Deleting and re-copying `multipaste.firstLaunchDate` from UserDefaults does NOT restart the trial (store a tamper-resilient marker; at minimum also use Keychain for the first-launch timestamp).

---

### Phase 6 - Packaging and distribution

Goal: a notarized `.dmg` file that a customer can download, open, drag to Applications, and run without any Gatekeeper warning.

**Tasks:**

**6a. Apple Developer account prerequisites.**
The user must have an Apple Developer Program account ($99/yr). Confirm before starting this phase. Required:
- A **Developer ID Application** certificate in Keychain.
- App-specific password for `notarytool` stored as `NOTARY_APP_PASSWORD` in the environment.
- Apple ID and Team ID available.

**6b. Add entitlements file.**
Create `multipaste.entitlements`:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.cs.allow-jit</key>
    <false/>
    <key>com.apple.security.cs.allow-unsigned-executable-memory</key>
    <false/>
    <key>com.apple.security.cs.disable-library-validation</key>
    <false/>
</dict>
</plist>
```
The app does NOT use the App Sandbox (`com.apple.security.app-sandbox` must be absent). A CGEventTap cannot run in a sandboxed app.

**6c. Code-sign.**
Add to `scripts/build-app.sh`:
```bash
IDENTITY="Developer ID Application: YOUR_NAME (TEAM_ID)"
codesign --force --deep --options runtime \
  --entitlements multipaste.entitlements \
  --sign "$IDENTITY" \
  Multipaste.app
```

**6d. Notarize and staple.**
```bash
xcrun notarytool submit Multipaste.app \
  --apple-id "YOUR_APPLE_ID" \
  --team-id "TEAM_ID" \
  --password "$NOTARY_APP_PASSWORD" \
  --wait

xcrun stapler staple Multipaste.app
```

**6e. Create the DMG.**
Use [`create-dmg`](https://github.com/create-dmg/create-dmg) (install via `brew install create-dmg`):
```bash
create-dmg \
  --volname "Multipaste" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 128 \
  --icon "Multipaste.app" 150 200 \
  --hide-extension "Multipaste.app" \
  --app-drop-link 450 200 \
  "Multipaste-1.0.0.dmg" \
  "Multipaste.app"
```

**6f. First-run onboarding.**
On first launch (check `UserDefaults("multipaste.onboardingComplete")`), show an `NSAlert` that:
1. Explains Accessibility permission is required.
2. Has a "Open System Settings" button that opens `x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility`.
3. After dismissal, polls `AXIsProcessTrusted()` every 2 seconds and shows a second confirmation dialog once granted.

**6g. README.md.**
Write a `README.md` in the project root with:
- One-sentence positioning ("Multipaste is the rapid-fire paste buffer for your next 10 seconds - not your next 10 days").
- Animated GIF or screenshot of Cycle & Drop and FIFO in action (add placeholder text for the user to fill in).
- System requirements (macOS 13 Ventura+).
- Installation steps (drag to Applications, grant Accessibility).
- Free vs Pro feature table (reuse from Section 2 of this spec).
- Link to the Gumroad/Lemon Squeezy purchase page (placeholder).
- License (MIT for the free tier; proprietary for Pro features, or simply "All rights reserved" with a personal use clause).

**Acceptance criteria for Phase 6:**
- Running `./scripts/build-app.sh` produces a codesigned, notarized `Multipaste.app` and a `Multipaste-1.0.0.dmg`.
- On a separate clean Mac user account (or a VM), mounting the DMG and dragging to Applications produces an app that opens without any Gatekeeper warning. Verify with `spctl --assess --type exec Multipaste.app`.
- `xcrun stapler validate Multipaste.app` reports "The validate action worked."
- First launch walks the user through Accessibility permission granting.
- README is present, accurate, and free of placeholder `YOUR_NAME` strings.

---

## 5. Testing

### XCTest target
Add a test target to `Package.swift`:
```swift
.testTarget(
    name: "multipaste-tests",
    dependencies: ["multipaste"] // may need to split multipaste into a library target first
)
```

Required test cases:
- `testConcealedClipIsNotStored()` - write a mock ClipboardManager that injects a concealed-type pasteboard change; assert DB count stays at 0.
- `testHistoryCapEnforced()` - insert 60 items; assert DB count is 50 (free tier cap).
- `testHistoryCapNotEnforcedOnPro()` - set license stub to `.pro`; insert 60 items; assert count is 60.
- `testLicenseActivationSuccess()` - mock the Gumroad API response with a successful JSON; assert `LicenseManager.state == .pro`.
- `testLicenseActivationFailure()` - mock a `{ "success": false }` response; assert state remains unchanged and an error is thrown.
- `testFIFOOrderPreserved()` - enqueue items A, B, C; simulate three `hotkeyManagerDidTriggerPaste()` calls; assert items are dequeued in order A, B, C.
- `testFIFORestoresPasteboard()` - set original pasteboard to "original"; enqueue and drain one FIFO item; assert pasteboard returns to "original".

### Manual checklist (run before calling any phase done)
- [ ] Build succeeds with `swift build -c release`.
- [ ] `Multipaste.app` launches without crashing in Console.
- [ ] Cycle & Drop works in TextEdit, Safari address bar, VS Code, Terminal.
- [ ] FIFO sequential paste works across three consecutive copies/pastes.
- [ ] Password manager copy does NOT appear in clipboard history.
- [ ] Tooltip appears at the text cursor, not at the screen corner.
- [ ] No `print()` output visible in Terminal when running the app.

---

## 6. Guardrails - what NOT to change

These parts of the codebase represent tested, working behavior. Extend them; do not rewrite them.

**`HotkeyManager` - the CGEventTap core**
The tap is registered at `.cgSessionEventTap` with `.headInsertEventTap`. This specific combination was chosen deliberately after testing. Changing the tap level or place breaks interception order with other apps. The event callback must remain non-blocking and must never make synchronous dispatch calls - a past deadlock was caused by exactly this. Any additions to the callback must be non-blocking (use `DispatchQueue.main.async`, never `.sync`).

**`ClipboardManager` - echo-suppression**
`isPasting` and `lastInjectedText` work together to prevent the app's own synthetic pastes from being re-captured as new clipboard entries. Both guards are needed. If you extend the paste injection path (e.g., for images), ensure both flags are set before writing to the pasteboard and cleared after.

**`DatabaseManager` schema migration**
Add columns to the existing `clips` table; never drop and recreate it. Use `ALTER TABLE ... ADD COLUMN` with `do/catch` (SQLite returns an error if the column already exists, which is safe to swallow). Users' existing clip history must survive an app update.

**Concurrency**
All current code runs on the main thread (Timer on `.common` RunLoop, HotkeyManager on the main run loop). This is intentional. If you need background work (e.g., async Gumroad API calls), use `Task { await ... }` from a MainActor context and `@MainActor` annotations where needed. Do not introduce raw `DispatchQueue.global()` calls without understanding the threading model.

---

## 7. Open decisions - ask the user before proceeding

| Decision | Needed for | Default assumption |
|---|---|---|
| `com.YOURNAME.multipaste` bundle ID | Phase 0 | No default; user must provide their Apple Developer short name |
| Gumroad vs Lemon Squeezy | Phase 5 | Gumroad (simpler API, no auth header needed for verify) |
| Gumroad product permalink | Phase 5 | No default; user must set up the product listing first |
| Reverse cycle hotkey | Phase 3 | Propose `Cmd+Shift+Z`; confirm with user |
| Apple Developer Team ID and Apple ID | Phase 6 | No default; user must provide |
| App icon design | Phase 0 | Placeholder acceptable for v1; replace before launch |

---

## 8. What to build after v1

These are explicitly out of scope for this spec. Do not implement them now.

- **On-device semantic search** using Apple's CoreML / NaturalLanguage framework to search history by meaning ("dinner recipe" finds a copied block of ingredients). A strong portfolio differentiator; add it after v1 ships.
- **Marketing landing page:** a single-page site with a demo GIF, pricing, and a Gumroad/Lemon Squeezy buy button.
- **iCloud sync:** syncing clipboard history across the user's Macs. Complex and out of scope for a "scalpel" tool.
- **iOS companion app:** distributing keystrokes and clipboard state to iPhone. Interesting, but App Store sandbox constraints make it hard.
