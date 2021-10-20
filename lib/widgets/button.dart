import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  const Button({
    Key? key,
    required this.text,
    required this.onTap,
  }) : super(key: key);

  final String text;
  final Function() onTap;

  @override
  State<Button> createState() => _ButtonState();
}

class _ButtonState extends State<Button> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: _onEnter,
      onExit: _onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: _hovered ? 1.08 : 1.0,
          child: AnimatedContainer(
            width: 225.0,
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: _hovered ? const Color(0xff2d8eff) : const Color(0xffffffff),
              border: Border.all(
                color: const Color(0xff2d8eff),
                width: 2.0,
              ),
              borderRadius: BorderRadius.circular(4.0),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: _hovered ? 12.0 : 0.0,
                ),
              ],
            ),
            child: Text(
              widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _hovered ? Colors.white : const Color(0xff2d8eff),
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onEnter(PointerEnterEvent _) {
    _hovered = true;
    setState(() {});
  }

  void _onExit(PointerExitEvent _) {
    _hovered = false;
    setState(() {});
  }
}
