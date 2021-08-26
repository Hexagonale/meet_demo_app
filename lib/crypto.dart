import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

class EncryptionResult extends Struct {
  @Int32()
  external int length;
  external Pointer<Uint8> data;
  external Pointer<NativeFunction<EncryptFree>> freePtr;

  void free() {
    freePtr.asFunction<Free>().call(data);
  }
}

typedef EncryptFree = Void Function(Pointer<Uint8> data);
typedef Free = void Function(Pointer<Uint8> data);

// FFI signature of the encrypt C function
typedef EncryptFunction = EncryptionResult Function(
  Pointer<Utf8> key,
  Pointer<Uint8> data,
  Int32 dataLen,
);

// Dart type definition for calling the C foreign function
typedef Encrypt = EncryptionResult Function(
  Pointer<Utf8> key,
  Pointer<Uint8> data,
  int dataLen,
);

// FFI signature of the encrypt C function
typedef DecryptFunction = EncryptionResult Function(
  Pointer<Utf8> key,
  Pointer<Uint8> data,
  Int32 dataLen,
);

// Dart type definition for calling the C foreign function
typedef Decrypt = EncryptionResult Function(
  Pointer<Utf8> key,
  Pointer<Uint8> data,
  int dataLen,
);

Uint8List encrypt({
  required String key,
  required Uint8List data,
}) {
  const String dllPath = 'ffi/Debug/crypto.dll';
  final DynamicLibrary lib = DynamicLibrary.open(dllPath);
  final encryptPointer = lib.lookup<NativeFunction<EncryptFunction>>('encrypt');
  final encrypt = encryptPointer.asFunction<Encrypt>();

  final Pointer<Utf8> encodedKey = key.toNativeUtf8();

  final Pointer<Uint8> encodedData = malloc<Uint8>(data.length);
  encodedData.asTypedList(data.length).setAll(0, data);

  final EncryptionResult result = encrypt(encodedKey, encodedData, data.length);

  final Uint8List copied = Uint8List(result.length);
  copied.setAll(0, result.data.asTypedList(result.length));
  result.free();

  return copied;
}

Uint8List decrypt({
  required String key,
  required Uint8List data,
}) {
  const String dllPath = 'ffi/Debug/crypto.dll';
  final DynamicLibrary lib = DynamicLibrary.open(dllPath);
  final encryptPointer = lib.lookup<NativeFunction<DecryptFunction>>('decrypt');
  final decrypt = encryptPointer.asFunction<Decrypt>();

  final Pointer<Utf8> encodedKey = key.toNativeUtf8();

  final Pointer<Uint8> encodedData = malloc<Uint8>(data.length);
  encodedData.asTypedList(data.length).setAll(0, data);

  final EncryptionResult result = decrypt(encodedKey, encodedData, data.length);

  final Uint8List copied = Uint8List(result.length);
  copied.setAll(0, result.data.asTypedList(result.length));
  result.free();

  return copied;
}
