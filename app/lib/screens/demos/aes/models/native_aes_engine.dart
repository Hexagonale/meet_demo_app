import 'dart:typed_data';

import 'package:native_crypto/native_crypto.dart';
import 'package:pointycastle/export.dart';

import 'aes_engine.dart';

/// AES Encryption engine that uses Native CPU implementation.
class NativeAesEngine extends AesEngine {
  NativeAesEngine({
    required Uint8List key,
    required Uint8List iv,
  }) : super(key, iv);

  AesCbcCipher? _aes;
  List<int> buffer = <int>[];

  @override
  Future<void> init() async {
    final SHA256Digest shaDigest = SHA256Digest();
    final AesCbcCipher cipher = AesCbcCipher();
    await cipher.init(
      key: shaDigest.process(key),
      initializationVector: iv,
      forEncryption: true,
    );

    _aes = cipher;
  }

  @override
  Future<Uint8List> add(Uint8List data) async {
    if (!ready) {
      throw Exception('Engine not ready');
    }

    _aes!.add(data);

    return await _aes!.stream.first;
  }

  @override
  Future<Uint8List> finish() async {
    if (!ready) {
      throw Exception('Engine not ready');
    }

    _aes!.close();

    final Uint8List cipher = await _aes!.stream.first;

    _aes = null;

    return cipher;
  }

  @override
  bool get ready => _aes != null;
}
