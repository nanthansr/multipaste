# Multipaste: The "Cycle & Drop" Clipboard Buffer

## 1. Product Vision & Philosophy
Multipaste is an ultra-minimalist, micro-SaaS macOS clipboard utility designed specifically to solve the "Short-Term Buffer" problem. 

**The Pain Point:** Existing clipboard managers (Raycast, Maccy, Paste) are built for *Long-Term Retrieval*. They force users to break their "flow state" by opening a UI, searching, and hitting Enter for every single paste. This makes sequential pasting (copying 3 items and pasting them in order) a slow, frustrating experience.
**The Solution:** Multipaste acts as a "scalpel." It provides a zero-friction muscle-memory solution for the next 10 seconds of rapid-fire pasting, living invisibly alongside long-term managers like Raycast.

**Core Mechanics:**
*   **Cycle & Drop:** Hold `Cmd+Shift`, tap `V` to cycle backward through recent clips. A translucent tooltip appears *exactly* at the text cursor. Release to instantly paste.
*   **FIFO Mode (First In, First Out):** A killer feature for developers and data-entry workers. Turn it on, copy multiple items in a row, and simply hit standard `Cmd+V` repeatedly to automatically paste them in the exact order they were copied.

**Brand Name Ideas (Brainstormed):** Reel, Shift, Echo, Slip, Vee.

---

## 2. Technical Stack
*   **Language:** Swift 5.9
*   **Frameworks:** 
    *   **AppKit:** For background execution (`LSUIElement`), Menu Bar, and window management.
    *   **SwiftUI:** For the modern, translucent tooltip UI (`VisualEffectView`).
    *   **CoreGraphics/Carbon:** Low-level `CGEventTap` to intercept global keystrokes and synthesize pastes.
    *   **Accessibility (AXUIElement):** To locate the exact pixel coordinates of the blinking text cursor globally across the OS.
*   **Database:** `SQLite.swift` for fast, limitless, thread-safe local storage (solving Maccy's 999-item limit UI lag).

---

## 3. Current Implementation Status (What has been built)

The core engine has been successfully built and stress-tested.

### Completed Components:
*   **Background Daemon (`multipaste.swift`, `AppDelegate.swift`):** App runs completely invisibly with a menu bar item ("MP") to toggle settings. Checks and prompts for necessary Accessibility permissions on launch.
*   **Clipboard Polling (`ClipboardManager.swift`):** Background timer polls `NSPasteboard` every 0.5s. It intelligently ignores synthetic pastes injected by the app itself to prevent infinite duplication loops.
*   **Local Storage (`DatabaseManager.swift`):** Automatically provisions an SQLite database in `~/Library/Application Support/multipaste/db.sqlite3` and logs unique clips.
*   **Global Event Interception (`HotkeyManager.swift`):** Successfully registers a `CGEventTap` at the `cgSessionEventTap` level. It swallows `Cmd+Shift+V` so the OS doesn't type 'v', and intercepts standard `Cmd+V` when FIFO mode is active.
*   **Caret Positioning (`TooltipManager.swift`):** Queries `kAXFocusedUIElementAttribute` to find the blinking cursor. If the target app (e.g., Electron apps like VS Code) blocks accessibility, it gracefully falls back to displaying the tooltip near the mouse cursor.
*   **FIFO Engine:** Fully functional. Tracks a queue of copied items and sequentially overrides `NSPasteboard` and synthesizes `CGEvent` key presses to drop them in order.

### Tested & Fixed Bugs:
*   **Fixed Deadlock:** Resolved a fatal crash caused by synchronous thread dispatching during high-speed `CGEventTap` interceptions.
*   **Fixed Paste Echoes:** Resolved an issue where the app's synthesized pastes were being re-captured by the polling engine and duplicated in the database.
*   **Stress Tested:** Survived the autonomous "Ralph Wiggum" loop, successfully handling rapid programmatic copying, hotkey injection, and sequential FIFO pasting without memory leaks or crashes.

---

## 4. Future Roadmap & Ideas

### Phase 1: Polish & UX
*   **Tooltip UI:** Refine the SwiftUI tooltip to look more "Apple Native" (better typography, drop shadows, dark mode support).
*   **Preferences Window:** Build a small SwiftUI settings pane to allow users to change the default hotkeys and clear the database.
*   **Launch at Login:** Add `SMAppService` to allow the app to automatically start when the Mac boots.

### Phase 2: The ML Portfolio Angle (Optional)
*   **Local Semantic Search:** As brainstormed, integrate Apple's CoreML / NaturalLanguage framework to generate on-device embeddings for copied text. This would allow users to search their history by *meaning* rather than exact keywords (e.g., searching "dinner recipe" finds a copied block of ingredients).

### Phase 3: Go-to-Market
*   **Packaging:** Code-sign and notarize the app using an Apple Developer account (required since global event taps prevent Mac App Store sandboxing).
*   **Distribution:** Create a DMG installer.
*   **Monetization:** Adopt a Freemium model. The core "Cycle & Drop" feature is free (to gain users and GitHub stars for the portfolio), while advanced features (like unlimited SQLite history, FIFO mode, or ML search) require a $19 one-time Lifetime Deal (LTD) purchase via Gumroad/Stripe.
