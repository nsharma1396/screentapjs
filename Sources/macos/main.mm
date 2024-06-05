#import "./mouseEventMonitor.h"
#import <napi.h>
#import <stdio.h>

Napi::Value StartHook(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  Napi::Function callback = info[0].As<Napi::Function>();
  startMouseMonitor(env, callback);
  return Napi::Boolean::New(env, true);
}

Napi::Value StopHook(const Napi::CallbackInfo &info) {
  Napi::Env env = info.Env();
  stopMouseMonitor();
  return Napi::Boolean::New(env, true);
}

Napi::Object Init(Napi::Env env, Napi::Object exports) {
  exports.Set(Napi::String::New(env, "start"),
              Napi::Function::New(env, StartHook));
  exports.Set(Napi::String::New(env, "stop"),
              Napi::Function::New(env, StopHook));
  return exports;
}

NODE_API_MODULE(addon, Init)
