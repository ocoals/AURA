import 'package:flutter/material.dart';

import '../../core/constants/app_gradients.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.child,
    this.gradient,
  });

  final Widget child;

  /// Defaults to [AppGradients.bgSoft].
  final LinearGradient? gradient;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient ?? AppGradients.bgSoft),
      child: child,
    );
  }
}
