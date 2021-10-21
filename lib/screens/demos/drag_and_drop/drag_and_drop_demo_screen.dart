import 'dart:io';

import 'package:fh_meet/routing/reval_route.dart';
import 'package:fh_meet/widgets/drop_zone.dart';
import 'package:flutter/material.dart';

class DragAndDropDemoScreen extends StatefulWidget {
  const DragAndDropDemoScreen({Key? key}) : super(key: key);

  static RevealRoute getRoute() {
    return RevealRoute(
      page: const DragAndDropDemoScreen(),
      maxRadius: 800.0,
      centerAlignment: Alignment.center,
    );
  }

  @override
  State<DragAndDropDemoScreen> createState() => _DragAndDropDemoScreenState();
}

class _DragAndDropDemoScreenState extends State<DragAndDropDemoScreen> {
  final Set<String> files = <String>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drag And Drop Demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              SizedBox(
                width: 500.0,
                height: 250.0,
                child: DropZone(
                  onFilesDropped: _onFilesDropped,
                ),
              ),
              const SizedBox(height: 24.0),
              Expanded(
                child: ListView.builder(
                  itemCount: files.length,
                  itemBuilder: _listItemBuilder,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listItemBuilder(BuildContext context, int i) {
    final String path = files.elementAt(i);

    Widget icon = const SizedBox();

    if (Directory(path).existsSync()) {
      icon = const Icon(Icons.folder_rounded);
    }

    if (File(path).existsSync()) {
      icon = const Icon(Icons.description_rounded);
    }

    if (Link(path).existsSync()) {
      icon = const Icon(Icons.link_rounded);
    }

    return ListTile(
      leading: icon,
      title: Text(path),
      trailing: IconButton(
        icon: const Icon(Icons.delete_rounded),
        onPressed: () {
          files.remove(path);
          setState(() {});
        },
      ),
    );
  }

  void _onFilesDropped(List<String> paths) {
    files.addAll(paths);

    setState(() {});
  }
}
