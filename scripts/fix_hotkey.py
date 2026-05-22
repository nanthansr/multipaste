with open('Sources/multipaste/HotkeyManager.swift', 'r') as f:
    hm = f.read()

hm = hm.replace(
"""protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyManagerDidTriggerCycle()
    func hotkeyManagerDidTriggerReverseCycle()
    func hotkeyManagerDidTriggerPaste() -> Bool
}""",
"""protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyManagerDidTriggerCycle()
    func hotkeyManagerDidTriggerReverseCycle()
    func hotkeyManagerDidTriggerPaste() -> Bool
    func hotkeyManagerDidReleaseModifiers()
}"""
)

with open('Sources/multipaste/HotkeyManager.swift', 'w') as f:
    f.write(hm)
