import 'package:cached_network_image/cached_network_image.dart';
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
  Future<List<DateTime>>? _historyFuture;
  AtlasDataRepository? _repository;
  DateTime _selectedHistoryDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = AppScope.maybeRead(context)?.atlasDataRepository;
    _future ??= _load();
    _historyFuture ??= _loadHistoryDates();
  }

  Future<AtlasDashboardSnapshot> _load() async {
    return _repository?.loadSnapshot() ?? emptyAtlasSnapshot();
  }

  void _refresh() {
    setState(() {
      _future = _load();
      _historyFuture = _loadHistoryDates();
    });
  }

  Future<List<DateTime>> _loadHistoryDates() async {
    return _repository?.loadWorkoutHistoryDates() ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data =
            snapshot.data ??
            _repository?.cachedSnapshot ??
            emptyAtlasSnapshot();
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
            _WorkoutVolumeCard(repository: _repository, snapshot: data),
            _WorkoutHistorySection(
              repository: _repository,
              historyFuture: _historyFuture!,
              selectedDate: _selectedHistoryDate,
              onDateSelected:
                  (date) => setState(() => _selectedHistoryDate = date),
            ),
          ],
        );
      },
    );
  }
}

class _WorkoutHistorySection extends StatelessWidget {
  const _WorkoutHistorySection({
    required this.repository,
    required this.historyFuture,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final AtlasDataRepository? repository;
  final Future<List<DateTime>> historyFuture;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

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
              const Expanded(child: SectionTitle('Workout History')),
              TextButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onDateSelected(picked);
                },
                icon: const Icon(Icons.calendar_month_rounded),
                label: const Text('Date'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Review any saved workout by date.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          FutureBuilder<List<DateTime>>(
            future: historyFuture,
            builder: (context, snapshot) {
              final dates = snapshot.data ?? const <DateTime>[];
              if (dates.isEmpty) {
                return const _EmptyChartMessage(
                  icon: Icons.history_rounded,
                  message: 'Saved workout reports will appear here.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: dates.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final date = dates[index];
                        return ChoiceChip(
                          label: Text(_shortDateLabel(date)),
                          selected: _sameDate(date, selectedDate),
                          onSelected: (_) => onDateSelected(date),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  _WorkoutReportCard(
                    key: ValueKey(_dateKey(selectedDate)),
                    repository: repository,
                    date: selectedDate,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WorkoutReportCard extends StatelessWidget {
  const _WorkoutReportCard({
    required this.repository,
    required this.date,
    super.key,
  });

  final AtlasDataRepository? repository;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasWorkoutReport?>(
      future: repository?.loadWorkoutReport(date),
      builder: (context, snapshot) {
        final report = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (report == null) {
          return _EmptyChartMessage(
            icon: Icons.event_busy_rounded,
            message: 'No workout saved on ${_longDateLabel(date)}.',
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(report.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${_longDateLabel(report.date)} / ${_durationLabel(report.duration)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ReportChip(label: '${report.totalExercises} exercises'),
                _ReportChip(label: '${report.totalSets} sets'),
                _ReportChip(label: '${report.totalReps} reps'),
                _ReportChip(
                  label: '${report.totalVolume.toStringAsFixed(0)} kg volume',
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (final exercise in report.exercises) ...[
              _ReportExerciseTile(exercise: exercise),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ReportChip extends StatelessWidget {
  const _ReportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: AtlasColors.accentSoft,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _ReportExerciseTile extends StatelessWidget {
  const _ReportExerciseTile({required this.exercise});

  final AtlasWorkoutExerciseLog exercise;

  @override
  Widget build(BuildContext context) {
    final mediaUrl =
        exercise.exercise?.previewGif ??
        exercise.exercise?.gifUrl ??
        exercise.exercise?.thumbnail ??
        exercise.exercise?.previewImage ??
        exercise.exercise?.imageUrl;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child:
                mediaUrl == null
                    ? Container(
                      width: 58,
                      height: 58,
                      color: AtlasColors.accentSoft,
                      child: const Icon(Icons.fitness_center_rounded),
                    )
                    : CachedNetworkImage(
                      imageUrl: mediaUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                    ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  exercise.sets
                      .map((set) {
                        final weight =
                            set.weight == 0
                                ? 'bodyweight'
                                : '${set.weight.toStringAsFixed(set.weight == set.weight.roundToDouble() ? 0 : 1)} ${set.weightUnit}';
                        return 'Set ${set.setNumber}: ${set.reps} reps x $weight';
                      })
                      .join('\n'),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
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

class _WorkoutVolumeCard extends StatelessWidget {
  const _WorkoutVolumeCard({required this.repository, required this.snapshot});

  final AtlasDataRepository? repository;
  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Weekly Volume'),
          const SizedBox(height: 8),
          Text(
            '${snapshot.completedThisWeek} of ${snapshot.weeklyTarget} workouts completed this week.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 22),
          FutureBuilder<List<double>>(
            future: repository?.loadWeeklyWorkoutVolumes(),
            builder: (context, snapshot) {
              final rawValues = snapshot.data ?? const <double>[];
              final maxValue = rawValues.fold<double>(
                0,
                (max, value) => value > max ? value : max,
              );
              if (maxValue <= 0) {
                return const _EmptyChartMessage(
                  icon: Icons.fitness_center_rounded,
                  message: 'Volume appears after a saved session with weights.',
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MockBarChart(
                    values: [for (final value in rawValues) value / maxValue],
                    labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                    color: AtlasColors.success,
                    semanticLabel: 'Weekly workout volume chart',
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Peak day: ${maxValue.toStringAsFixed(0)} kg lifted.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              );
            },
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

bool _sameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _dateKey(DateTime date) {
  return '${date.year}-${date.month}-${date.day}';
}

String _shortDateLabel(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final today = DateTime.now();
  final yesterday = today.subtract(const Duration(days: 1));
  if (_sameDate(date, today)) return 'Today';
  if (_sameDate(date, yesterday)) return 'Yesterday';
  return '${date.day} ${months[date.month - 1]}';
}

String _longDateLabel(DateTime date) {
  const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
}

String _durationLabel(Duration? duration) {
  if (duration == null || duration.inSeconds <= 0) {
    return 'Saved session';
  }
  if (duration.inMinutes < 1) {
    return '${duration.inSeconds}s';
  }
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) {
    return '${minutes}m';
  }
  return '${hours}h ${minutes}m';
}
