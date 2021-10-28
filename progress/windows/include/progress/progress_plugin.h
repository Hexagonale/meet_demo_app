#ifndef FLUTTER_PLUGIN_PROGRESS_PLUGIN_H_
#define FLUTTER_PLUGIN_PROGRESS_PLUGIN_H_

#include <windows.h>

#include <shobjidl.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C" {
#endif

FLUTTER_PLUGIN_EXPORT void ProgressPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#define SET_PROGRESS_METHOD "set_progress"
#define SET_TYPE_METHOD "set_type"

#define PROGRESS_TYPE_NO_PROGRESS "no_progress"
#define PROGRESS_TYPE_INDETERMINATE "indeterminate"
#define PROGRESS_TYPE_NORMAL "normal"
#define PROGRESS_TYPE_ERROR "error"
#define PROGRESS_TYPE_PAUSED "paused"

using namespace flutter;

class ProgressPlugin : public Plugin {
   public:
    static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

    ProgressPlugin(PluginRegistrarWindows* registrar);
    virtual ~ProgressPlugin();

   private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result);

    MethodChannel<EncodableValue>* channel;
    PluginRegistrarWindows* registrar;

    HWND getWindow();
    TBPFLAG translateType(std::string);
};

#endif  // FLUTTER_PLUGIN_PROGRESS_PLUGIN_H_
