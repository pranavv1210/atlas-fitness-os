import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/animated_counter_text.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/atlas_state_cards.dart';
import '../../../core/widgets/section_title.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Good Morning Pranav',
      title: 'Today',
      trailing: const _WeatherPill(),
      children: [
        const _QuoteCard(),
        const _MissionCard(),
        const _ScoreAndWeekRow(),
        const _ProgressOverview(),
        const _WeightAndWaterRow(),
        const AtlasLoadingStateCard(
          title: 'Readiness Insight',
          subtitle: 'A future loading state for recovery and wellness signals.',
        ),
        const _QuickActions(),
      ],
    );
  }
}

class _WeatherPill extends StatelessWidget {
  const _WeatherPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AtlasColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 17, color: AtlasColors.warning),
          const SizedBox(width: 7),
          Text('28 deg', style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Focus', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            'Strength is built quietly, one precise session at a time.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      color: AtlasColors.ink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const Spacer(),
              Text(
                'Day 1 of 5',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Today\'s Mission',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.62),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chest + Triceps',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MissionChip(
                  icon: Icons.timer_outlined,
                  label: '58 min',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MissionChip(
                  icon: Icons.repeat_outlined,
                  label: '18 sets',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => showWorkoutPreviewSheet(context),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Open Workout Preview'),
          ),
        ],
      ),
    );
  }
}

class _MissionChip extends StatelessWidget {
  const _MissionChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ScoreAndWeekRow extends StatelessWidget {
  const _ScoreAndWeekRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _FitnessScoreCard()),
        SizedBox(width: 14),
        Expanded(child: _WeeklyProgressCard()),
      ],
    );
  }
}

class _FitnessScoreCard extends StatelessWidget {
  const _FitnessScoreCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Fitness Score'),
          const SizedBox(height: 18),
          Center(
            child: AnimatedProgressRing(
              progress: 0.86,
              size: 116,
              color: AtlasColors.accent,
              trackColor: AtlasColors.accentSoft,
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedCounterText(
                    value: 86,
                    formatter: (value) => value.round().toString(),
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text('Prime', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Weekly Progress'),
          const SizedBox(height: 18),
          AnimatedCounterText(
            value: 4,
            formatter: (value) => '${value.round()} / 5',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 6),
          Text(
            'workouts complete',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 26),
          const AtlasProgressBar(value: 0.8, color: AtlasColors.success),
        ],
      ),
    );
  }
}

class _ProgressOverview extends StatelessWidget {
  const _ProgressOverview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        SectionTitle('Workout Progress'),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AtlasStatCard(
                label: 'Completed',
                value: '123',
                caption: 'sessions',
                icon: Icons.check_circle_outline,
                color: AtlasColors.success,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: AtlasStatCard(
                label: 'This Month',
                value: '18',
                caption: 'workouts',
                icon: Icons.calendar_month_outlined,
                color: AtlasColors.lilac,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _WeightAndWaterRow extends StatelessWidget {
  const _WeightAndWaterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: AtlasStatCard(
            label: 'Weight',
            value: '76.4 kg',
            caption: '-0.8 kg this month',
            icon: Icons.monitor_weight_outlined,
            color: AtlasColors.accent,
          ),
        ),
        SizedBox(width: 14),
        Expanded(
          child: AtlasStatCard(
            label: 'Water',
            value: 'Next 2:30',
            caption: 'hydration nudge',
            icon: Icons.water_drop_outlined,
            color: AtlasColors.warning,
          ),
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.add_chart_outlined,
        'Log Weight',
        () => showAtlasSnack(context, message: 'Weight logging preview'),
      ),
      (
        Icons.mood_outlined,
        'Mood',
        () => showAtlasSnack(context, message: 'Mood check-in preview'),
      ),
      (
        Icons.water_drop_outlined,
        'Water',
        () => showAtlasSnack(context, message: 'Hydration nudge preview'),
      ),
      (
        Icons.directions_run_outlined,
        'Cardio',
        () => showAtlasSnack(context, message: 'Cardio entry preview'),
      ),
    ];

    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final action in actions)
                AtlasPressable(
                  onTap: action.$3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AtlasColors.surfaceWarm,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AtlasColors.hairline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.$1, size: 18, color: AtlasColors.inkMuted),
                        const SizedBox(width: 8),
                        Text(
                          action.$2,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
