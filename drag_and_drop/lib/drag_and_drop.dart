import 'dart:async';

import 'package:flutter/services.dart';

class DragAndDrop {
  static const String _filesDroppedMethod = 'files_dropped';
  static const String _acceptDroppedFilesMethod = 'accept_dropped_files';

  static final MethodChannel _channel = const MethodChannel('drag_and_drop')..setMethodCallHandler(_onMethodReceived);

  static final StreamController<List<String>> _filesDroppedStreamController = StreamController<List<String>>();

  /// Emits dragged in files and directories paths.
  static final Stream<List<String>> filesDroppedStream = _filesDroppedStreamController.stream.asBroadcastStream();

  /// Sets if apps allow dragging in apps or not.
  static Future<bool> setAcceptDrop(bool accept) async {
    final bool? success = await _channel.invokeMethod(_acceptDroppedFilesMethod, accept);

    return success == true;
  }

  static Future<void> _onMethodReceived(MethodCall? methodCall) async {
    if (methodCall == null) {
      return;
    }

    switch (methodCall.method) {
      case _filesDroppedMethod:
        return await _onFilesDropped(methodCall.arguments);

      default:
        print('Unknown method ${methodCall.method}');
        break;
    }
  }

  static Future<void> _onFilesDropped(dynamic arguments) async {
    if (arguments is! List<Object?>) {
      print('[_onFilesDropped] Incorrect argument type');
      return;
    }

    final List<String> paths = [];
    for (final Object? path in arguments) {
      if (path == null) {
        print('[_onFilesDropped] Path is null');
        continue;
      }

      paths.add(path.toString());
    }

    _filesDroppedStreamController.add(paths);
  }
}
