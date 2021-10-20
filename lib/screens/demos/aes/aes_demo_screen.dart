import 'package:flutter/material.dart';

class AesDemoScreen extends StatelessWidget {
  const AesDemoScreen({Key? key}) : super(key: key);

  static MaterialPageRoute<Widget> getRoute() {
    return MaterialPageRoute<Widget>(
      builder: (BuildContext _) => const AesDemoScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('AesDemoScreen'),
      ),
    );
  }
}
