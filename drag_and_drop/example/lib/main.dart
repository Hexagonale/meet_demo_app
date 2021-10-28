import 'package:drag_and_drop/drag_and_drop.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Home(),
        ),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool accept = true;

  @override
  void initState() {
    super.initState();

    DragAndDrop.setAcceptDrop(true);
    DragAndDrop.filesDroppedStream.listen((List<String> files) {
      print('Files dropped: $files');
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(accept ? 'Disallow' : 'Allow'),
      onPressed: _onTapped,
    );
  }

  void _onTapped() {
    accept = !accept;
    DragAndDrop.setAcceptDrop(accept);
    setState(() {});
  }
}
