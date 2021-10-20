import 'package:flutter/material.dart';
import 'circular_reveal_clipper.dart';

class RevealRoute extends PageRouteBuilder<Widget> {
  /// Reveals the next item pushed to the navigation using circle shape.
  ///
  /// You can provide [centerAlignment] for the reveal center or if you want a
  /// more precise use only [centerOffset] and leave other blank.
  ///
  /// The transition doesn't affect the entry screen so we will only touch
  /// the target screen.
  RevealRoute({
    required this.page,
    required this.maxRadius,
    this.minRadius = 0,
    this.centerAlignment,
    this.centerOffset,
  })  : assert(centerOffset != null || centerAlignment != null),
        super(
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
  final double maxRadius;
  final double minRadius;
  final Alignment? centerAlignment;
  final Offset? centerOffset;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ClipPath(
      clipper: CircularRevealClipper(
        fraction: animation.value,
        centerAlignment: centerAlignment,
        centerOffset: centerOffset,
        minRadius: minRadius,
        maxRadius: maxRadius,
      ),
      child: child,
    );
  }
}
