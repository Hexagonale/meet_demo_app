import 'dart:ui';

import 'package:fh_meet/screens/demos/aes/aes_demo_screen.dart';
import 'package:fh_meet/screens/demos/drag_and_drop/drag_and_drop_demo_screen.dart';
import 'package:fh_meet/screens/demos/progress/progress_demo_screen.dart';
import 'package:fh_meet/screens/demos/sha256/sha256_demo_screen.dart';
import 'package:fh_meet/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  static MaterialPageRoute<Widget> getRoute() {
    return MaterialPageRoute<Widget>(
      builder: (BuildContext _) => HomeScreen(),
    );
  }

  final GlobalKey progressButtonKey = GlobalKey();
  final GlobalKey dragAndDropButtonKey = GlobalKey();
  final GlobalKey aesButtonKey = GlobalKey();
  final GlobalKey sha256ButtonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned(
            left: -150.0,
            top: -150.0,
            child: SvgPicture.asset(
              'assets/svg/blob1.svg',
              width: 450.0,
            ),
          ),
          Positioned(
            right: -250.0,
            bottom: -250.0,
            child: SvgPicture.asset(
              'assets/svg/blob2.svg',
              width: 600.0,
            ),
          ),
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    _buildTitle(),
                    _buildButtons(context),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return const SelectableText(
      'Flutter meetup #1 by Futurehome',
      style: TextStyle(
        fontSize: 48.0,
        color: Color(0xff2d8eff),
        fontWeight: FontWeight.w700,
        fontFamily: 'Comfortaa',
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: <Widget>[
        Button(
          key: progressButtonKey,
          text: 'Progress Demo',
          onTap: () => _goToProgress(context),
        ),
        const SizedBox(height: 12.0),
        Button(
          key: dragAndDropButtonKey,
          text: 'Drag and Drop Demo',
          onTap: () => _goToDragAndDrop(context),
        ),
        const SizedBox(height: 12.0),
        Button(
          key: aesButtonKey,
          text: 'AES Encryption Demo',
          onTap: () => _goToAes(context),
        ),
        const SizedBox(height: 12.0),
        Button(
          key: sha256ButtonKey,
          text: 'SHA256 GPU Demo',
          onTap: () => _goToSha256(context),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Text(
      'Curiosity is the first step to knowledge',
      style: TextStyle(
        fontSize: 18.0,
        color: Color(0xffc2c3c6),
        fontWeight: FontWeight.w500,
        letterSpacing: 3.5,
        fontFamily: 'Quicksand',
      ),
    );
  }

  void _goToProgress(BuildContext context) {
    Navigator.push(
      context,
      ProgressDemoScreen.getRoute(progressButtonKey),
    );
  }

  void _goToDragAndDrop(BuildContext context) {
    Navigator.push(
      context,
      DragAndDropDemoScreen.getRoute(dragAndDropButtonKey),
    );
  }

  void _goToAes(BuildContext context) {
    Navigator.push(
      context,
      AesDemoScreen.getRoute(aesButtonKey),
    );
  }

  void _goToSha256(BuildContext context) {
    Navigator.push(
      context,
      Sha256DemoScreen.getRoute(sha256ButtonKey),
    );
  }
}
