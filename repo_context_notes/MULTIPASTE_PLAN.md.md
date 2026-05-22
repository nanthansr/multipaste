---
file: MULTIPASTE_PLAN.md
size: 5144
mtime: 2026-05-21T11:30:10.991901Z
sha256: 2f23997c1c6adfe1d25bbca74ebadd0f78c5691af7cc4912675ac922084d21f5
---

# MULTIPASTE_PLAN.md

**Summary:** # Multipaste: The "Cycle & Drop" Clipboard Buffer

## Preview

```
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

The core engine has been successfully built and
```
