import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AnimatedProgressRing extends StatelessWidget {
  const AnimatedProgressRing({
    required this.progress,
    required this.center,
    this.size = 118,
    this.strokeWidth = 12,
    this.color = AtlasColors.accent,
    this.trackColor = AtlasColors.surfaceMuted,
    this.semanticLabel,
    super.key,
  });

  final double progress;
  final Widget center;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color trackColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          semanticLabel ??
          'Progress ${(progress.clamp(0, 1) * 100).round()} percent',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress.clamp(0, 1)),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return SizedBox.square(
            dimension: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: _RingPainter(
                    progress: value,
                    strokeWidth: strokeWidth,
                    color: color,
                    trackColor: trackColor,
                  ),
                ),
                child!,
              ],
            ),
          );
        },
        child: center,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final track =
        Paint()
          ..color = trackColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final progressPaint =
        Paint()
          ..shader = SweepGradient(
            startAngle: -math.pi / 2,
            endAngle: math.pi * 1.5,
            colors: [color.withValues(alpha: 0.55), color],
          ).createShader(rect)
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
