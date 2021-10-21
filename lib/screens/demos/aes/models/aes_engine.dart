import 'dart:typed_data';

abstract class AesEngine {
  AesEngine(this.key, this.iv);

  final Uint8List key;
  final Uint8List iv;

  Future<void> init();

  Future<Uint8List> add(Uint8List data);

  Future<Uint8List> finish();

  bool get ready;
}
