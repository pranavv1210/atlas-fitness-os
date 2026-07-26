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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill =
        color ??
        (isGlass
            ? (isDark ? const Color(0xD91A1C24) : AtlasColors.glass)
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.92));

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color:
              isGlass
                  ? Colors.white.withValues(alpha: isDark ? 0.12 : 0.42)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : AtlasColors.hairline),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.09),
            blurRadius: isGlass ? 34 : 26,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withValues(
              alpha: isDark ? 0.03 : (isGlass ? 0.86 : 0.42),
            ),
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
                    fill.withValues(alpha: isDark ? 0.88 : 0.78),
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
