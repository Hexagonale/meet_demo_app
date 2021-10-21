import 'dart:convert';
import 'dart:typed_data';

import 'package:fh_meet/routing/reval_route.dart';
import 'package:fh_meet/screens/demos/aes/models/native_aes_engine.dart';
import 'package:fh_meet/widgets/drop_zone.dart';
import 'package:flutter/material.dart';

import 'models/aes_engine_column_controller.dart';
import 'models/pc_aes_engine.dart';
import 'widgets/aes_engine_column.dart';

class AesDemoScreen extends StatefulWidget {
  const AesDemoScreen({Key? key}) : super(key: key);

  static RevealRoute getRoute() {
    return RevealRoute(
      page: const AesDemoScreen(),
      maxRadius: 800.0,
      centerAlignment: Alignment.center,
    );
  }

  @override
  State<AesDemoScreen> createState() => _AesDemoScreenState();
}

class _AesDemoScreenState extends State<AesDemoScreen> {
  final Uint8List key = Uint8List.fromList(utf8.encode('super-secret-key'));
  final Uint8List iv = Uint8List.fromList(<int>[1, 2, 3, 4, 5, 6, 7, 8, 1, 2, 3, 4, 5, 6, 7, 8]);

  final AesEngineColumnController _pcController = AesEngineColumnController();
  final AesEngineColumnController _nativeController = AesEngineColumnController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AES Demo'),
      ),
      body: SingleChildScrollView(
        child: Center(
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
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Expanded(
                      child: AesEngineColumn(
                        header: _buildColumnHeader(
                          title: 'PointyCastle',
                          icon: Icons.code_rounded,
                        ),
                        engine: PcAesEngine(
                          key: key,
                          iv: iv,
                        ),
                        controller: _pcController,
                      ),
                    ),
                    Expanded(
                      child: AesEngineColumn(
                        header: _buildColumnHeader(
                          title: 'Native',
                          icon: Icons.memory_rounded,
                        ),
                        engine: NativeAesEngine(
                          key: key,
                          iv: iv,
                        ),
                        controller: _nativeController,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColumnHeader({
    required String title,
    required IconData icon,
  }) {
    return Column(
      children: <Widget>[
        Icon(
          icon,
          size: 64.0,
          color: Colors.black45,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24.0,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _onFilesDropped(List<String> paths) async {
    await _pcController.start(paths.first);
    await _nativeController.start(paths.first);
  }
}
