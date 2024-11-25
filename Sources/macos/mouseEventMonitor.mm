#import "mouseEventMonitor.h"
#include <cstdio>
#include <thread>

id monitor;
id selfMonitor;

Napi::ThreadSafeFunction tsfn;
std::thread nativeThread;

struct EventData {
  std::string *eventName = nullptr;
  int displayId;
};

auto callback = [](Napi::Env env, Napi::Function jsCallback,
                   EventData *eventData) {
  Napi::Object eventResult = Napi::Object::New(env);
  eventResult.Set("eventName", (*(eventData->eventName)));
  eventResult.Set("displayId", eventData->displayId);
  jsCallback.Call(
      {Napi::String::New(env, *(eventData->eventName)), eventResult});
  delete eventData->eventName;
  delete eventData;
};

void handleMouseEvent(NSEvent *event) {
  EventData *eventData = new EventData();
  switch (event.type) {
  case NSEventTypeLeftMouseDown:
    eventData->eventName = new std::string("leftMouseDown");
    break;
  case NSEventTypeLeftMouseUp:
    eventData->eventName = new std::string("leftMouseUp");
    break;
  case NSEventTypeRightMouseDown:
    eventData->eventName = new std::string("rightMouseDown");
    break;
  case NSEventTypeRightMouseUp:
    eventData->eventName = new std::string("rightMouseUp");
    break;
  default:
    break;
  }
  if (!eventData->eventName) {
    delete eventData;
    return;
  }
  NSPoint locationInWindow = [event locationInWindow];
  NSRect locationRectInWindow =
      NSMakeRect(locationInWindow.x, locationInWindow.y, 0, 0);

  // Convert the location to screen coordinates
  NSPoint locationInScreen =
      [event.window convertRectToScreen:locationRectInWindow].origin;

  CGDirectDisplayID display;
  uint32_t matchingDisplayCount = 0;

  // Get the display that contains the point
  CGError error = CGGetDisplaysWithPoint(locationInScreen, 1, &display,
                                         &matchingDisplayCount);

  if (error == kCGErrorSuccess && matchingDisplayCount > 0) {
    eventData->displayId = display;
  } else {
    eventData->displayId = 0;
  }
}

void startMouseMonitor(Napi::Env env, Napi::Function windowCallback) {

  tsfn =
      Napi::ThreadSafeFunction::New(env, windowCallback, "MouseMonitor", 0, 1);

  nativeThread = std::thread([]() {
    NSEventMask eventMask = NSEventMaskLeftMouseDown | NSEventMaskLeftMouseUp |
                            NSEventMaskRightMouseDown | NSEventMaskRightMouseUp;
    monitor = [NSEvent addGlobalMonitorForEventsMatchingMask:eventMask
                                                     handler:^(NSEvent *event) {
                                                       handleMouseEvent(event);
                                                     }];
    selfMonitor =
        [NSEvent addLocalMonitorForEventsMatchingMask:eventMask
                                              handler:^(NSEvent *event) {
                                                handleMouseEvent(event);
                                                return event;
                                              }];
    [[NSRunLoop currentRunLoop] run];
  });
}

void stopMouseMonitor() {
  bool monitorRemoved = false;
  bool selfMonitorRemoved = false;
  if (monitor) {
    [NSEvent removeMonitor:monitor];
    monitorRemoved = true;
    monitor = nil;
  }
  if (selfMonitor) {
    [NSEvent removeMonitor:selfMonitor];
    selfMonitorRemoved = true;
    selfMonitor = nil;
  }
  if (monitorRemoved && selfMonitorRemoved && nativeThread.joinable()) {
    nativeThread.join();
  }
}
