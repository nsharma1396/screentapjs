#include <napi.h>
#include <thread>
#include <iostream>
#include <string>
#include <windows.h>

#define LEFT_MOUSEDOWN "leftMouseDown"
#define LEFT_MOUSEUP "leftMouseUp"
#define RIGHT_MOUSEDOWN "rightMouseDown"
#define RIGHT_MOUSEUP "rightMouseUp"
#define FOREGROUND_WINDOW_UPDATED "foregroundWindowUpdated"

static HHOOK hMouseHook;
static HWINEVENTHOOK hForegroundHook;
static HWINEVENTHOOK hMoveSizeEndHook;

std::thread nativeThread;
Napi::ThreadSafeFunction tsfn;

struct MouseData {
  HMONITOR hMonitor;
  std::string event;
};

auto callback = [](Napi::Env env, Napi::Function jsCallback, MouseData* data) {
  jsCallback.Call({
    Napi::String::New(env, data->event),
    Napi::Number::New(env, static_cast<double>(reinterpret_cast<intptr_t>(data->hMonitor)))
  });
  delete data;
};

// Function to get the monitor from the mouse coordinates
HMONITOR GetMonitorFromPoint(POINT pt) {
  return MonitorFromPoint(pt, MONITOR_DEFAULTTONEAREST);
}

void CALLBACK win_event_proc(HWINEVENTHOOK hook, DWORD event, HWND hwnd, LONG idObject, LONG idChild, DWORD dwEventThread, DWORD dwmsEventTime) {
  if (event == EVENT_SYSTEM_FOREGROUND || event == EVENT_SYSTEM_MOVESIZEEND) {
    MouseData* data = new MouseData();
    data->event = FOREGROUND_WINDOW_UPDATED;
    if (hwnd == NULL || !IsWindow(hwnd) || !IsWindowVisible(hwnd) || !IsWindowEnabled(hwnd)) {
      data->hMonitor = NULL;
      POINT pt;
      if (GetCursorPos(&pt)) {
        data->hMonitor = GetMonitorFromPoint(pt);
      }
    } else {
      RECT rect;
      if (GetWindowRect(hwnd, &rect)) {
        POINT pt = {rect.left, rect.top};
        data->hMonitor = GetMonitorFromPoint(pt);
      }
    }
    tsfn.NonBlockingCall(data, callback);
  }
}

// Mouse hook callback function
LRESULT CALLBACK MouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
  if (nCode >= 0) {
    bool isMouseClickEvent = wParam == WM_LBUTTONDOWN || wParam == WM_LBUTTONUP || wParam == WM_RBUTTONDOWN || wParam == WM_RBUTTONUP;
    if (!isMouseClickEvent) {
      return CallNextHookEx(hMouseHook, nCode, wParam, lParam);
    }
    PMSLLHOOKSTRUCT pMouseStruct = (PMSLLHOOKSTRUCT)lParam;
    HMONITOR hMonitor = GetMonitorFromPoint(pMouseStruct->pt);
    MouseData* data = new MouseData();
    data->hMonitor = hMonitor;
    switch (wParam) {
      case WM_LBUTTONDOWN:
          data->event = LEFT_MOUSEDOWN;
          break;
      case WM_LBUTTONUP:
          data->event = LEFT_MOUSEUP;
          break;
      case WM_RBUTTONDOWN:
          data->event = RIGHT_MOUSEDOWN; 
          break;
      case WM_RBUTTONUP:
          data->event = RIGHT_MOUSEUP;
          break;
    }
    tsfn.NonBlockingCall(data, callback);
  }
  return CallNextHookEx(hMouseHook, nCode, wParam, lParam);
}

Napi::Value startHook(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();

  Napi::Function callback = info[0].As<Napi::Function>();
  tsfn = Napi::ThreadSafeFunction::New(env, callback, "MouseHookJsCb", 0, 1);

  // create a native thread
  nativeThread = std::thread([]() {
    MSG msg;
    hMouseHook = SetWindowsHookEx(WH_MOUSE_LL, MouseProc, NULL, 0);
    hForegroundHook = SetWinEventHook(EVENT_SYSTEM_FOREGROUND, EVENT_SYSTEM_FOREGROUND, NULL, win_event_proc, 0, 0, WINEVENT_OUTOFCONTEXT);
    hMoveSizeEndHook = SetWinEventHook(EVENT_SYSTEM_MOVESIZEEND, EVENT_SYSTEM_MOVESIZEEND, NULL, win_event_proc, 0, 0, WINEVENT_OUTOFCONTEXT);
    if (hMouseHook == NULL) {
      std::cerr << "Failed to set mouse hook!" << std::endl;
    }
    while (GetMessage(&msg, NULL, 0, 0)) {
      TranslateMessage(&msg);
      DispatchMessage(&msg);
    }
  });
  return Napi::Boolean::New(env, true);
}

Napi::Value stopHook(const Napi::CallbackInfo& info) {
  Napi::Env env = info.Env();
  if (hMouseHook != NULL) {
    if (!UnhookWindowsHookEx(hMouseHook)) {
      std::cout << "Failed to unhook mouse hook!" << std::endl;
    }
    hMouseHook = NULL;
  }
  if (hForegroundHook != NULL) {
    if (!UnhookWinEvent(hForegroundHook)) {
      std::cout << "Failed to unhook foreground window hook!" << std::endl;
    }
    hForegroundHook = NULL;
  }
  if (hMoveSizeEndHook != NULL) {
    if (!UnhookWinEvent(hMoveSizeEndHook)) {
      std::cout << "Failed to unhook move size end hook!" << std::endl;
    }
    hMoveSizeEndHook = NULL;
  }
  return Napi::Boolean::New(env, true);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "start"), Napi::Function::New(env, startHook));
  exports.Set(Napi::String::New(env, "stop"), Napi::Function::New(env, stopHook));
  return exports;
}

NODE_API_MODULE(addon, Init)
