#pragma once
#include <CoreFoundation/CoreFoundation.h>
#include <CoreGraphics/CoreGraphics.h>
#include <napi.h>
#include <stdio.h>
#include <string>

CGEventRef mouseEventCallback(CGEventTapProxy proxy, CGEventType type,
                              CGEventRef event);

void startMouseMonitor(Napi::Env env, Napi::Function windowCallback);
void stopMouseMonitor();
