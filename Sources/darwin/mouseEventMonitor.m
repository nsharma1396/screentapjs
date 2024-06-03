#import <Cocoa/Cocoa.h>

void startMouseMonitor(void (*callback)(const char*, int));

static void (*jsCallback)(const char*, int);

void mouseEventCallback(CGEventType type, CGEventRef event) {
    const char *eventName = "";
    switch (type) {
        case kCGEventLeftMouseDown:
            eventName = "leftMouseDown";
            break;
        case kCGEventLeftMouseUp:
            eventName = "leftMouseUp";
            break;
        case kCGEventRightMouseDown:
            eventName = "rightMouseDown";
            break;
        case kCGEventRightMouseUp:
            eventName = "rightMouseUp";
            break;
        default:
            break;
    }

    CGEventSourceRef source = CGEventCreateSourceFromEvent(event);
    if (source) {
        CGDirectDisplayID display = CGMainDisplayID();
        jsCallback(eventName, (int)display);
        CFRelease(source);
    }
}

void startMouseMonitor(void (*callback)(const char*, int)) {
    jsCallback = callback;

    CGEventMask eventMask = (1 << kCGEventLeftMouseDown) |
                            (1 << kCGEventLeftMouseUp) |
                            (1 << kCGEventRightMouseDown) |
                            (1 << kCGEventRightMouseUp);

    CFMachPortRef eventTap = CGEventTapCreate(kCGHIDEventTap,
                                              kCGHeadInsertEventTap,
                                              0,
                                              eventMask,
                                              (CGEventTapCallBack)mouseEventCallback,
                                              NULL);

    if (!eventTap) {
        NSLog(@"Failed to create event tap");
        exit(1);
    }

    CFRunLoopSourceRef runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRunLoopRun();
}
