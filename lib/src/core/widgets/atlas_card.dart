import 'dart:ui';

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AtlasCard extends StatelessWidget {
  const AtlasCard({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.isGlass = false,
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isGlass;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color:
          color ??
          (isGlass ? AtlasColors.surface.withValues(alpha: 0.72) : null),
      child: Padding(padding: padding, child: child),
    );

    if (!isGlass) {
      return card;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: card,
      ),
    );
  }
}
