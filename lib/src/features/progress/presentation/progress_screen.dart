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
import '../../atlas/presentation/atlas_log_sheets.dart';
import '../../today/presentation/today_screen.dart';

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
    return _repository?.loadSnapshot() ?? emptyAtlasSnapshot();
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? emptyAtlasSnapshot();
        return AtlasAppFrame(
          subtitle: 'Trends from your logs',
          title: 'Progress',
          children: [
            _ProgressHero(
              snapshot: data,
              repository: _repository,
              onSaved: _refresh,
            ),
            _MetricGrid(snapshot: data),
            _WorkoutFrequencyCard(snapshot: data),
          ],
        );
      },
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero({
    required this.snapshot,
    required this.repository,
    required this.onSaved,
  });

  final AtlasDashboardSnapshot snapshot;
  final AtlasDataRepository? repository;
  final VoidCallback onSaved;

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
              TextButton(
                onPressed: () async {
                  final saved = await showAtlasWeightLogSheet(
                    context,
                    repository: repository,
                  );
                  if (saved) onSaved();
                },
                child: Text(
                  weight == null
                      ? 'Add weight'
                      : '${weight.toStringAsFixed(1)} ${snapshot.latestWeightUnit}',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AtlasColors.accent),
                ),
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
          if (weight == null)
            const _EmptyChartMessage(
              icon: Icons.monitor_weight_outlined,
              message: 'Log your first weight to start the trend line.',
            )
          else
            MockLineChart(
              values: List.filled(7, weight),
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
          value:
              snapshot.recoveryScore == null
                  ? 'No signal'
                  : '${snapshot.recoveryScore}%',
          caption:
              snapshot.recoveryScore == null
                  ? 'log hydration first'
                  : 'from logs',
          icon: Icons.bolt_rounded,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'Fitness Score',
          value: snapshot.fitnessScore?.toString() ?? 'No score',
          caption:
              snapshot.fitnessScore == null
                  ? 'log activity first'
                  : 'from logs',
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
          if (completed == 0)
            const _EmptyChartMessage(
              icon: Icons.fitness_center_rounded,
              message:
                  'Workout frequency appears after your first saved session.',
            )
          else
            MockBarChart(
              values: [
                for (var index = 0; index < 7; index++)
                  index < completed ? 1.0 : 0.0,
              ],
              labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
              color: AtlasColors.success,
              semanticLabel: 'Workout frequency chart',
            ),
        ],
      ),
    );
  }
}

class _EmptyChartMessage extends StatelessWidget {
  const _EmptyChartMessage({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AtlasColors.surfaceWarm,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AtlasColors.inkMuted),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
