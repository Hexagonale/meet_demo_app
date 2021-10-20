import 'dart:async';

import 'package:drag_and_drop/drag_and_drop.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class DropZone extends StatefulWidget {
  const DropZone({
    Key? key,
    required this.onFilesDropped,
  }) : super(key: key);

  final Function(List<String> files) onFilesDropped;

  @override
  State<DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<DropZone> {
  bool entered = false;
  StreamSubscription<dynamic>? _subscription;

  @override
  void initState() {
    super.initState();

    _subscription = DragAndDrop.filesDroppedStream.listen(_onFilesDropped);
    DragAndDrop.setAcceptDrop(true);
  }

  @override
  void dispose() {
    DragAndDrop.setAcceptDrop(false);
    _subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: DottedBorder(
        color: Colors.black26,
        strokeWidth: 6.0,
        borderType: BorderType.RRect,
        strokeCap: StrokeCap.round,
        dashPattern: const <double>[
          10.0,
          10.0,
        ],
        radius: const Radius.circular(16.0),
        child: const SizedBox(
          width: 500.0,
          height: 250.0,
          child: Center(
            child: Text(
              'Drop files here',
              style: TextStyle(
                color: Colors.black38,
                fontWeight: FontWeight.w600,
                fontSize: 28.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onEnter(PointerEvent event) {
    entered = true;
    setState(() {});
  }

  void _onExit(PointerEvent event) {
    entered = false;
    setState(() {});
  }

  Future<void> _onFilesDropped(List<String> files) async {
    // Wait for enter event to be registered.
    await Future<dynamic>.delayed(
      const Duration(milliseconds: 20),
    );

    if (entered) {
      widget.onFilesDropped(files);
    }
  }
}
