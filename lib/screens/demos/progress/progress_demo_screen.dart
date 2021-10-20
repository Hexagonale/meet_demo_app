import 'package:fh_meet/routing/reval_route.dart';
import 'package:flutter/material.dart';
import 'package:progress/progress.dart';

import 'widgets/progress_type_selector.dart';

class ProgressDemoScreen extends StatefulWidget {
  const ProgressDemoScreen({Key? key}) : super(key: key);

  static RevealRoute getRoute() {
    return RevealRoute(
      page: const ProgressDemoScreen(),
      maxRadius: 800.0,
      centerAlignment: Alignment.center,
    );
  }

  @override
  State<ProgressDemoScreen> createState() => _ProgressDemoScreenState();
}

class _ProgressDemoScreenState extends State<ProgressDemoScreen> {
  double _progress = 0.0;

  @override
  void dispose() {
    Progress.setType(ProgressType.noProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Slider(
              value: _progress,
              onChanged: _onSliderChanged,
            ),
            ProgressTypeSelector(
              onChanged: _onProgressTypeChanged,
            ),
          ],
        ),
      ),
    );
  }

  void _onSliderChanged(double value) {
    _progress = value;
    setState(() {});

    Progress.setProgress(_progress);
  }

  void _onProgressTypeChanged(ProgressType type) {
    Progress.setType(type);
  }
}
