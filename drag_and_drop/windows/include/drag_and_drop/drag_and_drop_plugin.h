#ifndef FLUTTER_PLUGIN_DRAG_AND_DROP_PLUGIN_H_
#define FLUTTER_PLUGIN_DRAG_AND_DROP_PLUGIN_H_

#include <windows.h>

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

FLUTTER_PLUGIN_EXPORT void DragAndDropPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
}  // extern "C"
#endif

#define FILES_DROPPED_METHOD "files_dropped"
#define ACCEPT_DROPPED_FILES_METHOD "accept_dropped_files"

using namespace flutter;

class DragAndDropPlugin : public Plugin {
   public:
    static void RegisterWithRegistrar(PluginRegistrarWindows* registrar);

    DragAndDropPlugin(PluginRegistrarWindows* _registrar);
    virtual ~DragAndDropPlugin();

   private:
    // Called when a method is called on this plugin's channel from Dart.
    void HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result);

    // Called for top-level WindowProc delegation.
    std::optional<LRESULT> HandleWindowProc(HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam);

    MethodChannel<EncodableValue>* channel;
    PluginRegistrarWindows* registrar;
    int wProcId;

    HWND getWindow();
    std::string utf8_encode(wchar_t* wstr, int size);
};

#endif  // FLUTTER_PLUGIN_DRAG_AND_DROP_PLUGIN_H_
