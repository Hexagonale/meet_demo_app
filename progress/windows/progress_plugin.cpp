#include "include/progress/progress_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <shobjidl.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

void ProgressPlugin::RegisterWithRegistrar(PluginRegistrarWindows* registrar) {
    std::unique_ptr<ProgressPlugin> plugin = std::make_unique<ProgressPlugin>(registrar);

    registrar->AddPlugin(std::move(plugin));
}

ProgressPlugin::ProgressPlugin(PluginRegistrarWindows* _registrar) {
    this->registrar = _registrar;
    this->channel = new MethodChannel<EncodableValue>(this->registrar->messenger(), "progress", &StandardMethodCodec::GetInstance());

    this->channel->SetMethodCallHandler([&](const auto& call, auto result) {
        this->HandleMethodCall(call, std::move(result));
    });
}

ProgressPlugin::~ProgressPlugin() {}

void ProgressPlugin::HandleMethodCall(const MethodCall<EncodableValue>& method_call, std::unique_ptr<MethodResult<EncodableValue>> result) {
    if (method_call.method_name().compare(SET_PROGRESS_METHOD) == 0) {
        const double progress = *std::get_if<double>(method_call.arguments());

        ITaskbarList3* taskbar;
        if (!SUCCEEDED(CoCreateInstance(CLSID_TaskbarList, 0, CLSCTX_INPROC_SERVER, IID_ITaskbarList3, (void**)&taskbar))) {
            result->Error("1", "Cannot create taskbar");
            return;
        }

        if (!SUCCEEDED(taskbar->HrInit())) {
            result->Error("2", "Cannot init taskbar");
            return;
        }

        if (!SUCCEEDED(taskbar->SetProgressValue(this->getWindow(), (ULONGLONG)(progress * 1000000), 1000000))) {
            result->Error("3", "Cannot set taskbar progress");
            return;
        }

        if (!SUCCEEDED(taskbar->Release())) {
            result->Error("4", "Cannot releae taskbar");
            return;
        }

        result->Success(flutter::EncodableValue(true));
        return;
    }

    if (method_call.method_name().compare(SET_TYPE_METHOD) == 0) {
        const std::string type = *std::get_if<std::string>(method_call.arguments());

        const TBPFLAG flag = this->translateType(type);

        ITaskbarList3* taskbar;
        if (!SUCCEEDED(CoCreateInstance(CLSID_TaskbarList, 0, CLSCTX_INPROC_SERVER, IID_ITaskbarList3, (void**)&taskbar))) {
            result->Error("1", "Cannot create taskbar");
            return;
        }

        if (!SUCCEEDED(taskbar->HrInit())) {
            result->Error("2", "Cannot init taskbar");
            return;
        }

        if (!SUCCEEDED(taskbar->SetProgressState(this->getWindow(), flag))) {
            result->Error("3", "Cannot set taskbar progress state");
            return;
        }

        if (!SUCCEEDED(taskbar->Release())) {
            result->Error("4", "Cannot releae taskbar");
            return;
        }

        result->Success(flutter::EncodableValue(true));
        return;
    }

    result->NotImplemented();
}
// namespace

// region Helpers
HWND ProgressPlugin::getWindow() {
    return GetAncestor(this->registrar->GetView()->GetNativeWindow(), GA_ROOT);
}

TBPFLAG ProgressPlugin::translateType(std::string type) {
    if (type.compare(PROGRESS_TYPE_NO_PROGRESS) == 0) {
        return TBPF_NOPROGRESS;
    }

    if (type.compare(PROGRESS_TYPE_INDETERMINATE) == 0) {
        return TBPF_INDETERMINATE;
    }

    if (type.compare(PROGRESS_TYPE_NORMAL) == 0) {
        return TBPF_NORMAL;
    }

    if (type.compare(PROGRESS_TYPE_ERROR) == 0) {
        return TBPF_ERROR;
    }

    if (type.compare(PROGRESS_TYPE_PAUSED) == 0) {
        return TBPF_PAUSED;
    }

    return TBPF_ERROR;
}
// endregion

void ProgressPluginRegisterWithRegistrar(FlutterDesktopPluginRegistrarRef registrar) {
    ProgressPlugin::RegisterWithRegistrar(PluginRegistrarManager::GetInstance()->GetRegistrar<PluginRegistrarWindows>(registrar));
}
