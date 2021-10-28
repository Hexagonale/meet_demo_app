import 'dart:async';

import 'package:flutter/services.dart';

class Progress {
  static const String _setProgressMethod = 'set_progress';
  static const String _setTypeMethod = "set_type";

  static const String _progressTypeNoProgress = "no_progress";
  static const String _progressTypeIndeterminate = "indeterminate";
  static const String _progressTypeNormal = "normal";
  static const String _progressTypeError = "error";
  static const String _progressTypePaused = "paused";

  static const MethodChannel _channel = MethodChannel('progress');

  /// Sets value for taskbar icon progress.
  static Future<bool> setProgress(double progress) async {
    final bool? success = await _channel.invokeMethod(_setProgressMethod, progress);

    return success == true;
  }

  /// Sets type for taskbar icon progress.
  static Future<bool> setType(ProgressType type) async {
    final String _type = _getProgressTypeString(type);
    final bool? success = await _channel.invokeMethod(_setTypeMethod, _type);

    return success == true;
  }

  static String _getProgressTypeString(ProgressType type) {
    switch (type) {
      case ProgressType.noProgress:
        return _progressTypeNoProgress;

      case ProgressType.indeterminate:
        return _progressTypeIndeterminate;

      case ProgressType.normal:
        return _progressTypeNormal;

      case ProgressType.error:
        return _progressTypeError;

      case ProgressType.paused:
        return _progressTypePaused;
    }
  }
}

enum ProgressType {
  noProgress,
  indeterminate,
  normal,
  error,
  paused,
}
