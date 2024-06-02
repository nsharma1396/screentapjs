#include <napi.h>
#include <thread>
#include <iostream>
#include <string>

extern "C" {
    void startMouseMonitor(void (*callback)(const char*, int));
}

Napi::ThreadSafeFunction tsfn;

void NativeCallback(const char* event, int monitor) {
    auto callback = [event, monitor](Napi::Env env, Napi::Function jsCallback) {
        jsCallback.Call({ Napi::String::New(env, event), Napi::Number::New(env, monitor) });
    };
    tsfn.BlockingCall(callback);
}

Napi::Value StartHook(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    Napi::Function callback = info[0].As<Napi::Function>();
    tsfn = Napi::ThreadSafeFunction::New(env, callback, "MouseHookJsCb", 0, 1);

    std::thread([]() {
        startMouseMonitor(NativeCallback);
    }).detach();

    return Napi::Boolean::New(env, true);
}

Napi::Value StopHook(const Napi::CallbackInfo& info) {
    // Not implemented in this example.
    // Add your logic to stop the hook if needed.
    return Napi::Boolean::New(info.Env(), true);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
    exports.Set(Napi::String::New(env, "start"), Napi::Function::New(env, StartHook));
    exports.Set(Napi::String::New(env, "stop"), Napi::Function::New(env, StopHook));
    return exports;
}

NODE_API_MODULE(addon, Init)
