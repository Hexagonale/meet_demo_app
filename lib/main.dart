import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'crypto.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home();

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(file ?? 'No file selected'),
          SizedBox(height: 16.0),
          Center(
            child: TextButton(
              child: Text('Select file'),
              onPressed: () async {
                // file = await FileOpener.openFile();
                // Crypto.encrypt('hello', Uint8List.fromList([0, 1, 2, 3, 4, 5, 6, 7, 8])).then(print);
                // setState(() {});

                try {
                  final Uint8List encrypted = encrypt(
                    key: 'hello hello hel',
                    data: Uint8List.fromList(utf8.encode('hello hello hello hello hello hello')),
                  );
                  print(encrypted.map((int e) => e.toRadixString(16)).join(', '));

                  final Uint8List decrypted = decrypt(
                    key: 'hello hello hel',
                    data: encrypted,
                  );
                  print(utf8.decode(decrypted));
                } catch (e, st) {
                  print(e);
                  print(st);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
