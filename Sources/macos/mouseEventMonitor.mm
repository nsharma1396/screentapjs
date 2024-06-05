#import "mouseEventMonitor.h"
#include <cstdio>
#include <thread>

Napi::ThreadSafeFunction tsfn;
CFRunLoopRef runLoop;
CFRunLoopSourceRef runLoopSource;
std::thread nativeThread;

struct EventData {
  std::string *eventName = nullptr;
  int displayId;
};

auto callback = [](Napi::Env env, Napi::Function jsCallback,
                   EventData *eventData) {
  jsCallback.Call({Napi::String::New(env, *(eventData->eventName)),
                   Napi::Number::New(env, eventData->displayId)});
  delete eventData;
};

CGEventRef mouseEventCallback(CGEventTapProxy proxy, CGEventType type,
                              CGEventRef event) {
  EventData *eventData = new EventData();
  switch (type) {
  case kCGEventLeftMouseDown:
    eventData->eventName = new std::string("leftMouseDown");
    break;
  case kCGEventLeftMouseUp:
    eventData->eventName = new std::string("leftMouseUp");
    break;
  case kCGEventRightMouseDown:
    eventData->eventName = new std::string("rightMouseDown");
    break;
  case kCGEventRightMouseUp:
    eventData->eventName = new std::string("rightMouseUp");
    break;
  default:
    break;
  }

  if (eventData->eventName == nullptr) {
    return event;
  }

  CGEventRef eventRef = CGEventCreate(NULL);
  if (eventRef) {
    CGPoint currentMouseLocation = CGEventGetLocation(eventRef);
    CFRelease(eventRef);

    CGDirectDisplayID display;

    CGGetDisplaysWithPoint(currentMouseLocation, 1, &display, NULL);

    eventData->displayId = display;
  }

  tsfn.NonBlockingCall(eventData, callback);

  return event;
}

void startMouseMonitor(Napi::Env env, Napi::Function windowCallback) {

  tsfn =
      Napi::ThreadSafeFunction::New(env, windowCallback, "MouseMonitor", 0, 1);

  nativeThread = std::thread([]() {
    CGEventMask eventMask =
        (1 << kCGEventLeftMouseDown) | (1 << kCGEventLeftMouseUp) |
        (1 << kCGEventRightMouseDown) | (1 << kCGEventRightMouseUp);
    CFMachPortRef eventTap = CGEventTapCreate(
        kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault,
        eventMask, (CGEventTapCallBack)mouseEventCallback, NULL);

    if (!eventTap) {
      printf("Failed to create event tap");
      exit(1);
    }

    runLoopSource =
        CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0);
    runLoop = CFRunLoopGetCurrent();
    CFRunLoopAddSource(runLoop, runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, true);
    CFRunLoopRun();
  });
}

void stopMouseMonitor() {
  if (runLoop) {
    CFRunLoopStop(runLoop);
    if (runLoopSource) {
      CFRelease(runLoopSource);
      runLoopSource = nullptr;
    }

    if (nativeThread.joinable()) {
      nativeThread.join();
    }
  }
}