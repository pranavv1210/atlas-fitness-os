import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AtlasProgressBar extends StatelessWidget {
  const AtlasProgressBar({
    required this.value,
    this.color = AtlasColors.accent,
    this.trackColor = AtlasColors.surfaceMuted,
    this.height = 8,
    this.semanticLabel,
    super.key,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          semanticLabel ??
          'Progress ${(value.clamp(0, 1) * 100).round()} percent',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: SizedBox(
              height: height,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: trackColor)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: value.clamp(0, 1)),
                    duration: const Duration(milliseconds: 850),
                    curve: Curves.easeOutCubic,
                    builder: (context, animatedValue, _) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: constraints.maxWidth * animatedValue,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(height / 2),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
