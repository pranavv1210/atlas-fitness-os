import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/section_title.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Real trends will appear here',
      title: 'Progress',
      children: const [
        _ProgressEmptyCard(),
        _ProgressMetricGrid(),
        _ChartEmptyCard(),
      ],
    );
  }
}

class _ProgressEmptyCard extends StatelessWidget {
  const _ProgressEmptyCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AtlasColors.accent, AtlasColors.accentDeep],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AtlasColors.accent.withValues(alpha: 0.24),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(Icons.insights_rounded, color: Colors.white),
          ),
          const SizedBox(height: 18),
          Text(
            'No progress data yet',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Weight, BMI, recovery, frequency, and charts will be calculated only after you log real entries.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class _ProgressMetricGrid extends StatelessWidget {
  const _ProgressMetricGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.04,
      ),
      children: const [
        AtlasStatCard(
          label: 'Weight Trend',
          value: 'No data yet',
          caption: 'first log pending',
          icon: Icons.monitor_weight_outlined,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'BMI',
          value: 'No data yet',
          caption: 'height and weight needed',
          icon: Icons.favorite_border_rounded,
          color: AtlasColors.rose,
        ),
        AtlasStatCard(
          label: 'Recovery',
          value: 'No data yet',
          caption: 'wellness inputs needed',
          icon: Icons.bolt_rounded,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'Frequency',
          value: 'No data yet',
          caption: 'workouts logged',
          icon: Icons.bar_chart_rounded,
          color: AtlasColors.lilac,
        ),
      ],
    );
  }
}

class _ChartEmptyCard extends StatelessWidget {
  const _ChartEmptyCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AtlasColors.surfaceMuted.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: AtlasColors.inkMuted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitle('Charts'),
                    const SizedBox(height: 6),
                    Text(
                      'Charts are hidden until there are enough real entries to draw a meaningful trend.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 126,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1100),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return CustomPaint(
                  painter: _EmptyChartPainter(value),
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyChartPainter extends CustomPainter {
  const _EmptyChartPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint =
        Paint()
          ..color = AtlasColors.ink.withValues(alpha: 0.05)
          ..strokeWidth = 1;
    for (final y in [
      size.height * 0.24,
      size.height * 0.52,
      size.height * 0.8,
    ]) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path =
        Path()
          ..moveTo(0, size.height * 0.68)
          ..cubicTo(
            size.width * 0.28,
            size.height * 0.46,
            size.width * 0.48,
            size.height * 0.88,
            size.width * 0.72,
            size.height * 0.5,
          )
          ..cubicTo(
            size.width * 0.84,
            size.height * 0.3,
            size.width * 0.94,
            size.height * 0.48,
            size.width,
            size.height * 0.38,
          );

    final visiblePath = Path();
    for (final metric in path.computeMetrics()) {
      visiblePath.addPath(
        metric.extractPath(0, metric.length * progress),
        Offset.zero,
      );
    }

    final linePaint =
        Paint()
          ..shader = const LinearGradient(
            colors: [AtlasColors.accent, AtlasColors.success],
          ).createShader(Offset.zero & size)
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;

    canvas.drawPath(visiblePath, linePaint);
  }

  @override
  bool shouldRepaint(covariant _EmptyChartPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
