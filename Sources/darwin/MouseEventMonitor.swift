import Cocoa

var jsCallback: ((String, Int) -> Void)?

print("hello there")

@_cdecl("startMouseMonitor")
public func startMouseMonitor(callback: @escaping (String, Int) -> Void) {
    jsCallback = callback
    
    let eventMask = (1 << CGEventType.leftMouseDown.rawValue) |
                    (1 << CGEventType.leftMouseUp.rawValue) |
                    (1 << CGEventType.rightMouseDown.rawValue) |
                    (1 << CGEventType.rightMouseUp.rawValue)

    guard let eventTap = CGEvent.tapCreate(tap: .cghidEventTap,
                                           place: .headInsertEventTap,
                                           options: .defaultTap,
                                           eventsOfInterest: CGEventMask(eventMask),
                                           callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
        let location = event.location
        let monitor = CGMainDisplayID()
        
        var eventName = ""
        switch type {
        case .leftMouseDown:
            eventName = "leftMouseDown"
        case .leftMouseUp:
            eventName = "leftMouseUp"
        case .rightMouseDown:
            eventName = "rightMouseDown"
        case .rightMouseUp:
            eventName = "rightMouseUp"
        default:
            break
        }

        jsCallback?(eventName, Int(monitor))
        return Unmanaged.passUnretained(event)
    }, userInfo: nil) else {
        print("Failed to create event tap")
        exit(1)
    }

    let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    CGEvent.tapEnable(tap: eventTap, enable: true)
    CFRunLoopRun()
}
