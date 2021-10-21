typedef StartCallback = Future<void> Function(String file);

class AesEngineColumnController {
  final List<StartCallback> _listeners = <StartCallback>[];

  Future<void> start(String file) async {
    await Future.wait(
      _listeners.map(
        (StartCallback listener) => listener(file),
      ),
    );
  }

  void onStart(StartCallback listener) {
    _listeners.add(listener);
  }
}
