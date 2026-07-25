import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AtlasCard extends StatelessWidget {
  const AtlasCard({
    required this.child,
    this.padding = const EdgeInsets.all(22),
    this.isGlass = false,
    this.color,
    this.radius = 30,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isGlass;
  final Color? color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final fill =
        color ??
        (isGlass
            ? AtlasColors.glass
            : AtlasColors.surface.withValues(alpha: 0.92));

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              isGlass
                  ? Colors.white.withValues(alpha: 0.42)
                  : AtlasColors.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: AtlasColors.shadow.withValues(alpha: isGlass ? 0.14 : 0.09),
            blurRadius: isGlass ? 34 : 26,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: isGlass ? 0.86 : 0.42),
            blurRadius: 10,
            offset: const Offset(-4, -5),
          ),
        ],
        gradient:
            isGlass
                ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.92),
                    fill.withValues(alpha: 0.78),
                  ],
                )
                : null,
      ),
      child: Padding(padding: padding, child: child),
    );

    if (!isGlass) {
      return card;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: card,
      ),
    );
  }
}
