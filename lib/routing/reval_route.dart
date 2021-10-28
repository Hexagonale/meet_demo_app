import 'package:flutter/material.dart';
import 'circular_reveal_clipper.dart';

/// Reveals the next item pushed to the navigation using circle shape.
///
/// The transition doesn't affect the entry screen so we will only touch the target screen.
/// 
/// Modified https://onetdev.medium.com/circle-reveal-page-route-transition-in-flutter-7b44460d22e2
class RevealRoute extends PageRouteBuilder<Widget> {
  RevealRoute({
    required this.page,
    required this.centerWidgetKey,
  }) : super(
          /// We could override pageBuilder but it's a required parameter of
          /// [PageRouteBuilder] and it won't build unless it's provided.
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) {
            return page;
          },
        );

  final Widget page;
  final GlobalKey centerWidgetKey;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final RenderBox box = centerWidgetKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;

    final Offset center = Offset(
      position.dx + (size.width / 2),
      position.dy + (size.height / 2),
    );

    return ClipPath(
      clipper: CircularRevealClipper(
        fraction: animation.value,
        center: center,
      ),
      child: child,
    );
  }
}
