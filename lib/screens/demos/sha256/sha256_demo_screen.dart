import 'package:flutter/material.dart';

class Sha256DemoScreen extends StatelessWidget {
  const Sha256DemoScreen({Key? key}) : super(key: key);

  static MaterialPageRoute<Widget> getRoute() {
    return MaterialPageRoute<Widget>(
      builder: (BuildContext _) => const Sha256DemoScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Sha256DemoScreen'),
      ),
    );
  }
}
