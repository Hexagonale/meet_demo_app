import 'dart:typed_data';

/// Abstract class for different implementations of AES encryption engine.
abstract class AesEngine {
  AesEngine(this.key, this.iv);

  final Uint8List key;
  final Uint8List iv;

  /// Initializes engine.
  Future<void> init();

  /// Encrypts given [data].
  Future<Uint8List> add(Uint8List data);

  /// Finishes encryption.
  Future<Uint8List> finish();

  /// Has engine been initialized.
  bool get ready;
}
