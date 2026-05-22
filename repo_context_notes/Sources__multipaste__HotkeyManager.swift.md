---
file: Sources/multipaste/HotkeyManager.swift
size: 3822
mtime: 2026-05-21T02:39:31.729438Z
sha256: cbe3dd155b495fd14cb38d15e63a75bc77887e824641ab654289abcc20494aea
---

# Sources/multipaste/HotkeyManager.swift

**Summary:** import AppKit

## Preview

```
import AppKit
import ApplicationServices
import Foundation

protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyManagerDidTriggerCycle()
    func hotkeyManagerDidReleaseModifiers()
    func hotkeyManagerDidTriggerPaste() -> Bool // Return true if handled (e.g. FIFO mode)
}

class HotkeyManager {
    static let shared = HotkeyManager()
    
    weak var delegate: HotkeyManagerDelegate?
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var isCycling = false
    
    private init() {}
    
    func start() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) | (1 << CGEventType.flagsChanged.rawValue)
        
        let observer = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                let manager = Unmanaged<HotkeyManager>.fromOpaque(refcon!).takeUnretainedValue()
                return manager.handleEvent(proxy: proxy, type: type, event: event)
            },
            userInfo: observer
        )
        
        guard let eventTap = eventTap else {
            print("Failed to create event tap. Ensure Accessibility permissions are granted.")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        print("Event tap started.")
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
```
