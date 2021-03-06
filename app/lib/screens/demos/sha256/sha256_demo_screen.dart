import 'package:fh_meet/routing/reval_route.dart';
import 'package:flutter/material.dart';

class Sha256DemoScreen extends StatelessWidget {
  const Sha256DemoScreen({Key? key}) : super(key: key);

  static RevealRoute getRoute(GlobalKey centerWidgetKey) {
    return RevealRoute(
      page: const Sha256DemoScreen(),
      centerWidgetKey: centerWidgetKey,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPU SHA256 Demo'),
      ),
      body: const Center(
        child: Text(
          'Another time :(',
          style: TextStyle(
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
