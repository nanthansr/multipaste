import os
import AppKit
import ApplicationServices
import Foundation

private let log = Logger(subsystem: "com.nanthansr.multipaste", category: "HotkeyManager")
protocol HotkeyManagerDelegate: AnyObject {
    func hotkeyManagerDidTriggerCycle()
    func hotkeyManagerDidTriggerReverseCycle()
    func hotkeyManagerDidTriggerPaste() -> Bool
    func hotkeyManagerDidReleaseModifiers()
    func hotkeyManagerDidOpenRadialHUD()
    func hotkeyManagerDidDismissRadialHUD()
}

class HotkeyManager {
    static let shared = HotkeyManager()
    
    weak var delegate: HotkeyManagerDelegate?
    
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    
    private var isCycling = false
    private var radialHUDTimer: Timer?
    private var isShowingRadialHUD = false

    private init() {}

    // Called by AppDelegate after the HUD is dismissed (via tile click or hide).
    func radialHUDDidDismiss() {
        isShowingRadialHUD = false
    }
    
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
            fileLog("Failed to create event tap. Ensure Accessibility permissions are granted.")
            return
        }
        
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        fileLog("Event tap started.")
    }
    
    func stop() {
        if let eventTap = eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
            if let runLoopSource = runLoopSource {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            }
        }
    }
    
    private func handleEvent(proxy: CGEventTapProxy, type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        let flags = event.flags
        let isCmdPressed = flags.contains(.maskCommand)
        let isShiftPressed = flags.contains(.maskShift)
        
        if type == .flagsChanged {
            if isCmdPressed && isShiftPressed {
                // Both modifiers now held - start radial HUD timer if not already cycling or showing
                if !isCycling && !isShowingRadialHUD && radialHUDTimer == nil {
                    radialHUDTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.isShowingRadialHUD = true
                            self.delegate?.hotkeyManagerDidOpenRadialHUD()
                        }
                    }
                }
            } else {
                // One or both modifiers released
                radialHUDTimer?.invalidate()
                radialHUDTimer = nil
                if isCycling {
                    isCycling = false
                    self.delegate?.hotkeyManagerDidReleaseModifiers()
                } else if isShowingRadialHUD {
                    isShowingRadialHUD = false
                    self.delegate?.hotkeyManagerDidDismissRadialHUD()
                }
            }
            return Unmanaged.passRetained(event)
        }

        if type == .keyDown {
            let keycode = event.getIntegerValueField(.keyboardEventKeycode)
            let vKeyCode: Int64 = 9 // 'v' key

            if isCmdPressed && isShiftPressed && keycode == vKeyCode {
                // V pressed while Cmd+Shift held: cancel radial timer, enter cycle mode
                radialHUDTimer?.invalidate()
                radialHUDTimer = nil
                isCycling = true
                self.delegate?.hotkeyManagerDidTriggerCycle()
                // Swallow the event so 'v' isn't typed
                return nil
            } else if isCmdPressed && !isShiftPressed && keycode == vKeyCode {
                // Standard Cmd+V
                let handled = self.delegate?.hotkeyManagerDidTriggerPaste() ?? false
                if handled {
                    // If handled (e.g. FIFO mode injected its own paste), we might want to swallow this event
                    // Wait, if we swallow it, the paste won't happen.
                    // Actually, if FIFO mode handles it, it will set the pasteboard and we SHOULD let this Cmd+V pass through to trigger the actual paste!
                    // So we don't swallow it, we just let it pass after the delegate updates the pasteboard.
                }
            }
        }
        
        return Unmanaged.passRetained(event)
    }
}
