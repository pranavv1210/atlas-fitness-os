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
    final scheme = Theme.of(context).colorScheme;
    final fill =
        color ??
        (isGlass
            ? (isDark ? const Color(0xE611151D) : AtlasColors.glass)
            : scheme.surface.withValues(alpha: isDark ? 0.94 : 0.92));
    final borderColor =
        isGlass
            ? (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.42))
            : (isDark
                ? Colors.white.withValues(alpha: 0.08)
                : AtlasColors.hairline);
    final gradientColors =
        isDark
            ? [const Color(0xF0141820), const Color(0xF00A0D13)]
            : [
              Colors.white.withValues(alpha: 0.92),
              fill.withValues(alpha: 0.78),
            ];

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.32 : 0.09),
            blurRadius: isGlass ? 34 : 26,
            offset: const Offset(0, 18),
          ),
          if (!isDark)
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
                  colors: gradientColors,
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
