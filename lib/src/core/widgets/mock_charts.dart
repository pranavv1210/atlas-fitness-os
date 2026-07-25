import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class MockLineChart extends StatelessWidget {
  const MockLineChart({
    required this.values,
    this.color = AtlasColors.accent,
    this.height = 150,
    this.semanticLabel = 'Line chart',
    super.key,
  });

  final List<double> values;
  final Color color;
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          return SizedBox(
            height: height,
            child: CustomPaint(
              painter: _LineChartPainter(
                values: values,
                color: color,
                progress: progress,
              ),
              child: const SizedBox.expand(),
            ),
          );
        },
      ),
    );
  }
}

class MockBarChart extends StatelessWidget {
  const MockBarChart({
    required this.values,
    required this.labels,
    this.color = AtlasColors.accent,
    this.height = 150,
    this.semanticLabel = 'Bar chart',
    super.key,
  });

  final List<double> values;
  final List<String> labels;
  final Color color;
  final double height;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: SizedBox(
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var index = 0; index < values.length; index++) ...[
              Expanded(
                child: _AnimatedBar(
                  value: values[index],
                  label: labels[index],
                  color: color,
                ),
              ),
              if (index != values.length - 1) const SizedBox(width: 9),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnimatedBar extends StatelessWidget {
  const _AnimatedBar({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.clamp(0, 1)),
              duration: const Duration(milliseconds: 850),
              curve: Curves.easeOutCubic,
              builder: (context, animatedValue, _) {
                return FractionallySizedBox(
                  heightFactor: math.max(animatedValue, 0.06),
                  widthFactor: 1,
                  alignment: Alignment.bottomCenter,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(
                        alpha: 0.18 + animatedValue * 0.62,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
        ),
      ],
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.values,
    required this.color,
    required this.progress,
  });

  final List<double> values;
  final Color color;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = math.max(maxValue - minValue, 0.1);
    final points = <Offset>[];

    for (var index = 0; index < values.length; index++) {
      final x = size.width * index / (values.length - 1);
      final normalized = (values[index] - minValue) / range;
      final y = size.height - (normalized * size.height * 0.72) - 18;
      points.add(Offset(x, y));
    }

    final animatedCount = math.max(2, (points.length * progress).ceil());
    final visiblePoints = points.take(animatedCount).toList();
    final path = Path()..moveTo(visiblePoints.first.dx, visiblePoints.first.dy);

    for (var index = 1; index < visiblePoints.length; index++) {
      final previous = visiblePoints[index - 1];
      final current = visiblePoints[index];
      final controlX = (previous.dx + current.dx) / 2;
      path.cubicTo(
        controlX,
        previous.dy,
        controlX,
        current.dy,
        current.dx,
        current.dy,
      );
    }

    final fillPath =
        Path.from(path)
          ..lineTo(visiblePoints.last.dx, size.height)
          ..lineTo(visiblePoints.first.dx, size.height)
          ..close();

    final fillPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.16), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size);

    final linePaint =
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

    final gridPaint =
        Paint()
          ..color = AtlasColors.ink.withValues(alpha: 0.05)
          ..strokeWidth = 1;

    for (final y in [
      size.height * 0.25,
      size.height * 0.55,
      size.height * 0.85,
    ]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
    canvas.drawCircle(visiblePoints.last, 4.5, Paint()..color = color);
    canvas.drawCircle(
      visiblePoints.last,
      8,
      Paint()..color = color.withValues(alpha: 0.16),
    );
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.values != values ||
        oldDelegate.color != color;
  }
}
