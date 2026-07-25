import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/atlas_state_cards.dart';
import '../../../core/widgets/mock_charts.dart';
import '../../../core/widgets/section_title.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Trends without noise',
      title: 'Progress',
      children: const [
        _WeightTrendCard(),
        _StatsGrid(),
        _WorkoutFrequencyCard(),
        _MonthlyProgressCard(),
        _CardioEmptyState(),
      ],
    );
  }
}

class _WeightTrendCard extends StatelessWidget {
  const _WeightTrendCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('Weight Trend')),
              Text(
                '76.4 kg',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AtlasColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '-0.8 kg in 30 days',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const MockLineChart(
            values: [77.2, 77.0, 76.9, 76.8, 76.5, 76.7, 76.4],
            color: AtlasColors.accent,
          ),
          const SizedBox(height: 10),
          const _ChartFooter(left: '30 days ago', right: 'Today'),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: AtlasStatCard(
            label: 'BMI',
            value: '23.4',
            caption: 'healthy range',
            icon: Icons.favorite_border,
            color: AtlasColors.rose,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: AtlasStatCard(
            label: 'Recovery',
            value: '82%',
            caption: 'ready to train',
            icon: Icons.battery_charging_full_outlined,
            color: AtlasColors.success,
          ),
        ),
      ],
    );
  }
}

class _WorkoutFrequencyCard extends StatelessWidget {
  const _WorkoutFrequencyCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Workout Frequency'),
          const SizedBox(height: 6),
          Text(
            '4.5 sessions per week',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          const MockBarChart(
            values: [0.62, 0.82, 0.58, 1, 0.76, 0.9, 0.7],
            labels: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            color: AtlasColors.success,
            height: 136,
          ),
          const SizedBox(height: 10),
          const _ChartFooter(left: 'Light', right: 'Strong'),
        ],
      ),
    );
  }
}

class _CardioEmptyState extends StatelessWidget {
  const _CardioEmptyState();

  @override
  Widget build(BuildContext context) {
    return AtlasEmptyStateCard(
      icon: Icons.directions_run_outlined,
      title: 'Cardio Timeline',
      body: 'No cardio sessions are shown in the prototype yet.',
      actionLabel: 'Preview future empty state',
      onAction: () {},
    );
  }
}

class _ChartFooter extends StatelessWidget {
  const _ChartFooter({required this.left, required this.right});

  final String left;
  final String right;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(left, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(right, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _MonthlyProgressCard extends StatelessWidget {
  const _MonthlyProgressCard();

  @override
  Widget build(BuildContext context) {
    const rows = [
      ('Strength sessions', '18 / 22', 0.82, AtlasColors.accent),
      ('Cardio minutes', '142 / 180', 0.78, AtlasColors.warning),
      ('Recovery logs', '24 / 30', 0.8, AtlasColors.lilac),
    ];

    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Monthly Progress'),
          const SizedBox(height: 18),
          for (final row in rows) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    row.$1,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(row.$2, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            const SizedBox(height: 10),
            AtlasProgressBar(value: row.$3, color: row.$4),
            if (row != rows.last) const SizedBox(height: 18),
          ],
        ],
      ),
    );
  }
}
