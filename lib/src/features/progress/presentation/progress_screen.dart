import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/mock_charts.dart';
import '../../../core/widgets/section_title.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  Future<AtlasDashboardSnapshot>? _future;
  AtlasDataRepository? _repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = AppScope.maybeRead(context)?.atlasDataRepository;
    _future ??= _load();
  }

  Future<AtlasDashboardSnapshot> _load() async {
    return _repository?.loadSnapshot() ?? _fallbackSnapshot();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _fallbackSnapshot();
        return AtlasAppFrame(
          subtitle: 'Trends from your logs',
          title: 'Progress',
          children: [
            _ProgressHero(snapshot: data),
            _MetricGrid(snapshot: data),
            _WorkoutFrequencyCard(snapshot: data),
          ],
        );
      },
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final weight = snapshot.latestWeight;
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: SectionTitle('Weight Trend')),
              Text(
                weight == null
                    ? 'Add weight'
                    : '${weight.toStringAsFixed(1)} ${snapshot.latestWeightUnit}',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: AtlasColors.accent),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            weight == null
                ? 'Log weight from Today to start this chart.'
                : 'Latest measurement from your saved logs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          MockLineChart(
            values:
                weight == null
                    ? const [1, 1, 1, 1, 1, 1, 1]
                    : [
                      weight + 0.4,
                      weight + 0.2,
                      weight + 0.1,
                      weight,
                      weight + 0.05,
                      weight - 0.05,
                      weight,
                    ],
            color: AtlasColors.accent,
            semanticLabel: 'Weight trend chart',
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

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
      children: [
        AtlasStatCard(
          label: 'Workouts',
          value: '${snapshot.totalWorkouts}',
          caption: 'all time',
          icon: Icons.check_circle_outline,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'This Month',
          value: '${snapshot.monthWorkouts}',
          caption: 'sessions',
          icon: Icons.calendar_month_rounded,
          color: AtlasColors.lilac,
        ),
        AtlasStatCard(
          label: 'Recovery',
          value: '${snapshot.recoveryScore}%',
          caption: 'derived signal',
          icon: Icons.bolt_rounded,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'Fitness Score',
          value: '${snapshot.fitnessScore}',
          caption: 'from logs',
          icon: Icons.speed_rounded,
          color: AtlasColors.accent,
        ),
      ],
    );
  }
}

class _WorkoutFrequencyCard extends StatelessWidget {
  const _WorkoutFrequencyCard({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final completed = snapshot.completedThisWeek;
    final values = <double>[
      0.12,
      0.22,
      0.18,
      (completed / snapshot.weeklyTarget).clamp(0.08, 1).toDouble(),
      0.16,
      0.2,
      0.14,
    ];
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Workout Frequency'),
          const SizedBox(height: 8),
          Text(
            '$completed of ${snapshot.weeklyTarget} workouts completed this week.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          MockBarChart(
            values: values,
            labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
            color: AtlasColors.success,
            semanticLabel: 'Workout frequency chart',
          ),
        ],
      ),
    );
  }
}

AtlasDashboardSnapshot _fallbackSnapshot() {
  final today = fallbackCycle.first;
  return AtlasDashboardSnapshot(
    todayWorkout: today,
    templateExercises: fallbackPlan(today.name, fallbackExercises),
    exerciseLibrary: fallbackExercises,
    completedThisWeek: 0,
    weeklyTarget: 5,
    totalWorkouts: 0,
    monthWorkouts: 0,
    hydrationToday: 0,
    activeGoals: const [],
  );
}
