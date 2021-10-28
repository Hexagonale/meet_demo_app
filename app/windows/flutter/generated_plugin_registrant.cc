//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <drag_and_drop/drag_and_drop_plugin.h>
#include <native_crypto/native_crypto_plugin.h>
#include <progress/progress_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  DragAndDropPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DragAndDropPlugin"));
  NativeCryptoPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("NativeCryptoPlugin"));
  ProgressPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ProgressPlugin"));
}
