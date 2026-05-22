import re

# 1. TooltipManager.swift
with open('Sources/multipaste/TooltipManager.swift', 'r') as f:
    tm = f.read()

# Replace screen handling
old_screen = "let screen = NSScreen.main ?? NSScreen.screens[0]"
new_screen = "let screen = NSScreen.screens.first(where: { $0.frame.contains(pos) }) ?? NSScreen.main ?? NSScreen.screens[0]"
if old_screen in tm:
    tm = tm.replace(old_screen, new_screen)

with open('Sources/multipaste/TooltipManager.swift', 'w') as f:
    f.write(tm)

# 2. HotkeyManager.swift
with open('Sources/multipaste/HotkeyManager.swift', 'r') as f:
    hm = f.read()

protocol_add = """protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyManagerDidTriggerCycle()
    func hotkeyManagerDidTriggerReverseCycle()
    func hotkeyManagerDidTriggerPaste() -> Bool
}"""
if "func hotkeyManagerDidTriggerReverseCycle()" not in hm:
    hm = re.sub(r'protocol HotkeyManagerDelegate: AnyObject \{.*?\n\}', protocol_add, hm, flags=re.DOTALL)

event_handling = """
        if eventType == .keyDown {
            let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
            let flags = event.flags
            
            let isCmdDown = flags.contains(.maskCommand)
            let isShiftDown = flags.contains(.maskShift)
            
            // Cmd+Shift+V
            if keyCode == vKeyCode && isCmdDown && isShiftDown {
                DispatchQueue.main.async {
                    self.delegate?.hotkeyManagerDidTriggerCycle()
                }
                return nil // swallow
            }
            
            // Cmd+Shift+Z (Reverse Cycle)
            let zKeyCode: Int64 = 6
            if keyCode == zKeyCode && isCmdDown && isShiftDown {
                DispatchQueue.main.async {
                    self.delegate?.hotkeyManagerDidTriggerReverseCycle()
                }
                return nil // swallow
            }
"""
if "zKeyCode" not in hm:
    hm = re.sub(r'if eventType == \.keyDown \{.*?// Cmd\+Shift\+V.*?return nil // swallow\n            \}', event_handling, hm, flags=re.DOTALL)

with open('Sources/multipaste/HotkeyManager.swift', 'w') as f:
    f.write(hm)

# 3. AppDelegate.swift
with open('Sources/multipaste/AppDelegate.swift', 'r') as f:
    ad = f.read()

reverse_logic = """
    func hotkeyManagerDidTriggerReverseCycle() {
        guard !clips.isEmpty else { return }
        if currentIndex == -1 { currentIndex = 0 }
        currentIndex = (currentIndex - 1 + clips.count) % clips.count
        
        let clip = clips[currentIndex]
        TooltipManager.shared.showTooltip(clip: clip, index: currentIndex, total: clips.count)
    }
"""
if "func hotkeyManagerDidTriggerReverseCycle()" not in ad:
    ad = ad.replace("func hotkeyManagerDidTriggerCycle() {", reverse_logic + "\n    func hotkeyManagerDidTriggerCycle() {")

# 4. FIFO Harden
fifo_vars = """
    private var isFIFOModeEnabled = false
    private var originalPasteboardContent: String?
"""
ad = ad.replace("private var isFIFOModeEnabled = false", fifo_vars)

fifo_harden_paste = """
    func hotkeyManagerDidTriggerPaste() -> Bool {
        guard isFIFOModeEnabled, !fifoQueue.isEmpty else { return false }
        
        if fifoQueue.count == 1 { // Last item to dequeue soon
             originalPasteboardContent = NSPasteboard.general.string(forType: .string)
        }
        
        let text = fifoQueue.removeFirst()
        log.debug("FIFO pasting: \\(text). Remaining: \\(self.fifoQueue.count)")
        
        ClipboardManager.shared.isPasting = true
        ClipboardManager.shared.setPasteboard(content: text)
        
        if fifoQueue.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                if let original = self.originalPasteboardContent {
                    ClipboardManager.shared.setPasteboard(content: original)
                }
            }
        }
        
        return true
    }
"""
ad = re.sub(r'func hotkeyManagerDidTriggerPaste\(\) -> Bool \{.*?return true\n    \}', fifo_harden_paste, ad, flags=re.DOTALL)

with open('Sources/multipaste/AppDelegate.swift', 'w') as f:
    f.write(ad)

