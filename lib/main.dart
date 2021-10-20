import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:drag_and_drop/drag_and_drop.dart';
import 'package:file_opener/file_opener.dart';
import 'package:flutter/material.dart';
import 'package:native_crypto/native_crypto.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/block/aes_fast.dart';
import 'package:pointycastle/block/modes/cbc.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:progress/progress.dart';

import 'screens/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Meet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Montserrat'
      ),
      home: const HomeScreen(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription<dynamic>? _dragAndDropSubscription;
  String? file;

  @override
  void initState() {
    super.initState();

    _dragAndDropSubscription = DragAndDrop.filesDroppedStream.listen((List<String> event) {
      if (event.isEmpty) {
        return;
      }

      file = event.first;
      setState(() {});
      encrypt(File(file!));
    });
    DragAndDrop.setAcceptDrop(true);
  }

  @override
  void dispose() {
    DragAndDrop.setAcceptDrop(false);
    _dragAndDropSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // encrypt(File('C:\\Users\\Przemek\\Dysk Google\\Desktop\\key'));

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(file ?? 'No file selected'),
          SizedBox(height: 16.0),
          Center(
            child: Column(
              children: [
                TextButton(
                  child: Text('Select file'),
                  onPressed: () async {
                    file = await FileOpener.openFile();
                    if (file == null) {
                      return;
                    }

                    setState(() {});

                    encrypt(File(file!));
                  },
                ),
                TextButton(
                  child: Text('Redo'),
                  onPressed: () async {
                    if (file == null) {
                      return;
                    }

                    encrypt(File(file!));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> encrypt(File file) async {
    final Uint8List key = Uint8List.fromList(utf8.encode('super-secret-key'));
    final Uint8List iv = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8]);
    final Uint8List data = file.readAsBytesSync();

    print('start');

    final Stopwatch sw = Stopwatch()..start();

    final List<int> dataMy = await encryptMy(
      key: key,
      iv: iv,
      file: file,
      // data: data,
    );
    sw.stop();
    final int timeMy = sw.elapsedMilliseconds;
    print('My: ${file.statSync().size / 1024 / 1024 * 1000 / timeMy}MB/s');

    sw.reset();

    sw.start();

    final List<int> dataPc = await encryptPc(
      key: key,
      iv: iv,
      file: file,
      // data: data,
    );

    sw.stop();
    print('Pc: ${file.statSync().size / 1024 / 1024 * 1000 / sw.elapsedMilliseconds}MB/s');

    print('Pc / My: ${(sw.elapsedMilliseconds / timeMy).toStringAsFixed(2)}');

    if (dataMy.length != dataPc.length) {
      print('Lengths dont match ${dataMy.length} vs ${dataPc.length}!');

      return;
    }

    for (int i = 0; i < dataMy.length; i++) {
      if (dataMy[i] != dataPc[i]) {
        print(
            '${dataMy.sublist(i, 16).map((e) => e.toRadixString(16))} vs ${dataPc.sublist(i, 16).map((e) => e.toRadixString(16))}');
        print('Error on $i!');
        return;
      }
    }

    // print(
    //     '${dataMy.sublist(0, 16).map((e) => e.toRadixString(16))} vs ${dataPc.sublist(0, 16).map((e) => e.toRadixString(16))}');

    print('No errors!');
  }

  Future<List<int>> encryptMy({
    required Uint8List key,
    required Uint8List iv,
    required File file,
  }) async {
    final SHA256Digest shaDigest = SHA256Digest();
    final AesCbcCipher cipher = AesCbcCipher();
    await cipher.init(
      key: shaDigest.process(key),
      initializationVector: iv,
      forEncryption: true,
    );

    final List<int> out = [];
    final StreamSubscription sub = cipher.stream.listen((Uint8List data) {
      out.addAll(data);
    });

    final int size = file.statSync().size;
    int encrypted = 0;

    final Stream<List<int>> stream = file.openRead();
    await for (List<int> chunk in stream) {
      final Uint8List data = Uint8List.fromList(chunk);

      await cipher.add(data);
      encrypted += data.length;
      Progress.setProgress(encrypted / size);
      // Random r = Random();
      // await cipher.add(Uint8List.fromList(List.generate(1024 * 1024, (index) => r.nextInt(255))));
    }

    await cipher.close();
    await sub.cancel();

    Progress.setProgress(0);

    return out;
  }

  Future<List<int>> encryptPc({
    required Uint8List key,
    required Uint8List iv,
    required File file,
    // required Uint8List data,
  }) async {
    final SHA256Digest shaDigest = SHA256Digest();
    final CBCBlockCipher aes = CBCBlockCipher(AESFastEngine());
    final KeyParameter keyParameter = KeyParameter(shaDigest.process(key));
    aes.init(true, ParametersWithIV(keyParameter, iv));

    final List<int> out = [];
    List<int> buffer = [];

    final int size = file.statSync().size;
    int encrypted = 0;

    final Stream<List<int>> stream = file.openRead();
    await for (List<int> chunk in stream) {
      Uint8List data = Uint8List.fromList([...buffer, ...chunk]);
      if (buffer.isNotEmpty) {
        data = Uint8List.fromList([...buffer, ...data]);
        buffer = [];
      }

      final int overflow = data.length % 16;
      if (overflow != 0) {
        buffer = data.sublist(data.length - overflow);
        data = data.sublist(0, data.length - overflow);
      }

      // Data is smaller than block size. Save it to the buffer.
      if (data.length == 0) {
        continue;
      }

      Uint8List cipher = Uint8List(data.length);

      int offset = 0;
      while (offset <= data.length - 16) {
        offset += aes.processBlock(data, offset, cipher, offset);
      }

      encrypted += cipher.length;
      Progress.setProgress(encrypted / size);
      out.addAll(cipher);
    }

    Uint8List cipher = Uint8List(16);
    final Uint8List finalBlock = BytesPadding.addPKCS(
      data: Uint8List.fromList(buffer),
      length: 16,
    );
    aes.processBlock(finalBlock, 0, cipher, 0);
    out.addAll(cipher);

    Progress.setProgress(0);

    return out;
  }
}
