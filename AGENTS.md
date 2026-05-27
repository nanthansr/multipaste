# Multipaste - project context for AI coding sessions

## Read this first

Before writing any code, read `HANDOFF.md` in this directory. It is the primary pickup document for all AI agents and contains the exact current state of the project.

After that, read `MULTIPASTE_V1_SPEC.md`. It is the authoritative build spec. Everything you need - architecture decisions, phase plan, acceptance criteria, file-level pointers, guardrails - is in that document. Do not re-derive context that is already there.

## Project state

The core Swift engine is **already built and working**. Your job is to build the product around it, not rewrite it.

Source files in `Sources/multipaste/`:
- `multipaste.swift` - entry point
- `AppDelegate.swift` - menu bar, cycle/paste logic
- `ClipboardManager.swift` - 0.5s pasteboard polling + echo-suppression
- `DatabaseManager.swift` - SQLite storage
- `HotkeyManager.swift` - global CGEventTap
- `TooltipManager.swift` + `TooltipView.swift` - caret-positioned tooltip

## Hard rules

1. **Do not rewrite the CGEventTap + echo-suppression core.** `HotkeyManager.swift` and the `isPasting`/`lastInjectedText` guards in `ClipboardManager.swift` are tested and working. Extend them; do not replace them. The Guardrails section of `MULTIPASTE_V1_SPEC.md` explains the prior bugs that made this necessary.
2. **Never use `2>&1`** in shell commands. Keep stdout and stderr separate.
3. **Work phase by phase.** Complete all acceptance criteria for the current phase before moving to the next.
4. **Ask the user** for the items listed in Section 7 ("Open decisions") of the spec before implementing Phases 0, 5, or 6.

## How to start each session

1. Read `MULTIPASTE_V1_SPEC.md`.
2. Check git log (or ask) to find the current phase.
3. State which phase you are starting and list any open decisions you need answered.
