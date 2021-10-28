#include "include/drag_and_drop/drag_and_drop_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

#pragma warning(disable : 4267)
#pragma warning(disable : 4018)
#pragma warning(disable : 4189)

using namespace flutter;

// region Static
void DragAndDropPlugin::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
    std::unique_ptr<DragAndDropPlugin> plugin = std::make_unique<DragAndDropPlugin>(registrar);

    registrar->AddPlugin(std::move(plugin));
}
// endregion

// region DragAndDropPlugin
DragAndDropPlugin::DragAndDropPlugin(PluginRegistrarWindows* _registrar) {
    this->registrar = _registrar;
    this->channel = new MethodChannel<EncodableValue>(this->registrar->messenger(), "drag_and_drop", &StandardMethodCodec::GetInstance());

    this->channel->SetMethodCallHandler([&](const auto& call, auto result) {
        this->HandleMethodCall(call, std::move(result));
    });

    this->wProcId = this->registrar->RegisterTopLevelWindowProcDelegate([&](HWND hwnd, UINT message, WPARAM wparam, LPARAM lparam) {
        return HandleWindowProc(hwnd, message, wparam, lparam);
    });
}

DragAndDropPlugin::~DragAndDropPlugin() {
    this->registrar->UnregisterTopLevelWindowProcDelegate(this->wProcId);

    delete channel;
}

std::optional<LRESULT> DragAndDropPlugin::HandleWindowProc(HWND _hwnd, UINT message, WPARAM wParam, LPARAM lParam) {
    if (message == WM_DROPFILES) {
        HDROP drop = (HDROP)wParam;

        // If second parameter is "0xFFFFFFFF", returns the count of files dropped.
        uint32_t filesCount = DragQueryFileW(drop, 0xFFFFFFFF, NULL, 512);

        EncodableList paths = {};

        for (uint32_t i = 0; i < filesCount; ++i) {
            // If third parameter is NULL, returns path length not counting the trailing '0'.
            uint32_t pathLength = DragQueryFileW(drop, i, NULL, 512) + 1;
            wchar_t* path = (wchar_t*)malloc(sizeof(wchar_t) * pathLength);

            DragQueryFileW(drop, i, path, pathLength);
            paths.push_back(EncodableValue(utf8_encode(path, pathLength)));

            free(path);
        }

        DragFinish(drop);

        this->channel->InvokeMethod(FILES_DROPPED_METHOD, std::make_unique<EncodableValue>(paths));
    }

    return std::nullopt;
}

void DragAndDropPlugin::HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result) {
    if (method_call.method_name().compare(ACCEPT_DROPPED_FILES_METHOD) == 0) {
        const bool accept = *std::get_if<bool>(method_call.arguments());

        DragAcceptFiles(this->getWindow(), accept);

        result->Success(flutter::EncodableValue(true));
        return;
    }

    result->NotImplemented();
}
// endregion

// region Helpers
HWND DragAndDropPlugin::getWindow() {
    return GetAncestor(this->registrar->GetView()->GetNativeWindow(), GA_ROOT);
}

std::string DragAndDropPlugin::utf8_encode(wchar_t* wstr, int size) {
    if (size == 0) {
        return std::string();
    }

    int size_needed = WideCharToMultiByte(CP_UTF8, 0, wstr, size, NULL, 0, NULL, NULL);
    std::string strTo(size_needed, 0);

    WideCharToMultiByte(CP_UTF8, 0, wstr, size, &strTo[0], size_needed, NULL, NULL);
    return strTo;
}
// endregion

// region Registrar
void DragAndDropPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    DragAndDropPlugin::RegisterWithRegistrar(PluginRegistrarManager::GetInstance()->GetRegistrar<PluginRegistrarWindows>(registrar));
}
// endregion