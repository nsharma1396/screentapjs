#pragma once
#include <AppKit/AppKit.h>
#include <napi.h>
#include <stdio.h>
#include <string>

void startMouseMonitor(Napi::Env env, Napi::Function windowCallback);
void stopMouseMonitor();
