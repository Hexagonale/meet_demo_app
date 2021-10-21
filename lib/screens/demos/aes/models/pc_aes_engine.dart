import 'dart:typed_data';

import 'package:native_crypto/native_crypto.dart';
import 'package:pointycastle/export.dart';

import 'aes_engine.dart';

/// AES Encryption engine that uses PointyCastle implementation.
class PcAesEngine extends AesEngine {
  PcAesEngine({
    required Uint8List key,
    required Uint8List iv,
  }) : super(key, iv);

  CBCBlockCipher? _aes;
  List<int> _buffer = <int>[];

  @override
  Future<void> init() async {
    final SHA256Digest shaDigest = SHA256Digest();
    final CBCBlockCipher aes = CBCBlockCipher(AESFastEngine());
    final KeyParameter keyParameter = KeyParameter(shaDigest.process(key));

    aes.init(true, ParametersWithIV<KeyParameter>(keyParameter, iv));

    _aes = aes;
  }

  @override
  Future<Uint8List> add(Uint8List data) async {
    if (!ready) {
      throw Exception('Engine not ready');
    }

    if (data.isEmpty) {
      return Uint8List(0);
    }

    if (_buffer.isNotEmpty) {
      data = Uint8List.fromList(<int>[..._buffer, ...data]);
      _buffer = Uint8List(0);
    }

    final int overflow = data.length % 16;
    if (overflow != 0) {
      _buffer = data.sublist(data.length - overflow);
      data = data.sublist(0, data.length - overflow);
    }

    // Data is smaller than block size. Save it to the buffer.
    if (data.isEmpty) {
      return Uint8List(0);
    }

    final Uint8List cipher = Uint8List(data.length);
    int offset = 0;

    while (offset <= data.length - 16) {
      offset += _aes!.processBlock(data, offset, cipher, offset);
    }

    return cipher;
  }

  @override
  Future<Uint8List> finish() async {
    if (!ready) {
      throw Exception('Engine not ready');
    }

    final Uint8List data = BytesPadding.addPKCS(
      data: Uint8List.fromList(_buffer),
      length: 16,
    );

    final Uint8List cipher = Uint8List(data.length);
    _aes!.processBlock(data, 0, cipher, 0);

    _aes = null;

    return cipher;
  }

  @override
  bool get ready => _aes != null;
}
