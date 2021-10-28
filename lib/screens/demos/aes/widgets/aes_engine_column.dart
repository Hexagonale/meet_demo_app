import 'dart:io';
import 'dart:typed_data';

import 'package:fh_meet/screens/demos/aes/models/aes_engine.dart';
import 'package:fh_meet/screens/demos/aes/models/aes_engine_column_controller.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:progress/progress.dart';

class AesEngineColumn extends StatefulWidget {
  const AesEngineColumn({
    Key? key,
    required this.header,
    required this.engine,
    required this.controller,
  }) : super(key: key);

  final Widget header;
  final AesEngine engine;
  final AesEngineColumnController controller;

  @override
  _AesEngineColumnState createState() => _AesEngineColumnState();
}

class _AesEngineColumnState extends State<AesEngineColumn> {
  final Stopwatch _stopwatch = Stopwatch();
  double _progress = 0.0;
  String? _checksum;
  double? _speed;

  @override
  void initState() {
    super.initState();

    widget.controller.onStart(_start);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        widget.header,
        const SizedBox(height: 32.0),
        _buildProgress(),
        const SizedBox(height: 32.0),
        _buildSummary(),
      ],
    );
  }

  Widget _buildProgress() {
    final String minutes = _stopwatch.elapsed.inMinutes.toString().padLeft(2, '0');
    final String seconds = (_stopwatch.elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return SizedBox(
      width: 100.0,
      height: 100.0,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: CircularProgressIndicator(
              strokeWidth: 5.0,
              value: _progress,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Text(
                '$minutes:$seconds',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    if (_checksum == null || _speed == null) {
      return const SizedBox();
    }

    final double speedInMegaBytes = _speed! / 1024 / 1024;

    return Column(
      children: <Widget>[
        _buildRow(
          title: 'Cipher text SHA256 checksum:',
          content: _checksum!,
        ),
        const SizedBox(height: 24.0),
        _buildRow(
          title: 'Encryption speed:',
          content: '${speedInMegaBytes.toStringAsFixed(2)} MB/s',
        ),
      ],
    );
  }

  Widget _buildRow({
    required String title,
    required String content,
  }) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }

  Future<void> _start(String path) async {
    final File file = File(path);
    if (!file.existsSync()) {
      return;
    }

    final SHA256Digest shaDigest = SHA256Digest();

    _stopwatch.reset();
    _stopwatch.start();

    await widget.engine.init();

    final int size = file.statSync().size;
    int encrypted = 0;

    /// Open stream to read a file.
    final Stream<List<int>> stream = file.openRead();
    await for (List<int> chunk in stream) {
      final Uint8List data = Uint8List.fromList(chunk);

      /// Encrypt data and hash cipher text.
      final Uint8List cipher = await widget.engine.add(data);
      shaDigest.process(cipher);

      encrypted += data.length;

      _progress = encrypted / size;
      Progress.setProgress(_progress);
      setState(() {});
    }

    final Uint8List cipher = await widget.engine.finish();
    shaDigest.process(cipher);

    _stopwatch.stop();

    _checksum = shaDigest.state.map((int el) => el.toRadixString(16)).join();
    _speed = (size / _stopwatch.elapsedMicroseconds) * 1000 * 1000;
    setState(() {});

    Progress.setProgress(0.0);
  }
}
