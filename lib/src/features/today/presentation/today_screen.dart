import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';
import '../../profile/domain/models/user_profile.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
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

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(widget.profile);
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _fallbackSnapshot();
        return AtlasAppFrame(
          subtitle: '${_greeting(DateTime.now())} $firstName',
          title: 'Today',
          trailing: _StatusPill(
            text: '${data.completedThisWeek}/${data.weeklyTarget} week',
          ),
          children: [
            _FocusCard(snapshot: data),
            _MissionCard(snapshot: data),
            _MetricsGrid(snapshot: data),
            _ReadinessCard(snapshot: data),
            _QuickActionsCard(repository: _repository, onSaved: _refresh),
          ],
        );
      },
    );
  }

  String _firstName(UserProfile profile) {
    final name = profile.displayName.trim();
    if (name.isNotEmpty) {
      return name.split(RegExp(r'\s+')).first;
    }
    final emailName = profile.email.split('@').first.trim();
    return emailName.isEmpty ? 'there' : emailName;
  }

  String _greeting(DateTime now) {
    if (now.hour < 12) {
      return 'Good Morning';
    }
    if (now.hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AtlasColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AtlasColors.accent.withValues(alpha: 0.16)),
      ),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AtlasColors.accent),
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final focus =
        snapshot.lastWorkoutTitle == null
            ? 'Start with one clean entry today. Atlas will build the operating system around your real training.'
            : 'Last completed: ${snapshot.lastWorkoutTitle}. Keep the cycle moving with today\'s session.';
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Focus', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(focus, style: Theme.of(context).textTheme.headlineMedium),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final workout = snapshot.todayWorkout;
    final progress =
        snapshot.weeklyTarget == 0
            ? 0.0
            : snapshot.completedThisWeek / snapshot.weeklyTarget;
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF111111),
                    AtlasColors.accentDeep.withValues(alpha: 0.96),
                    AtlasColors.ink,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const _FloatingWorkoutGlyph(),
                    const Spacer(),
                    AnimatedProgressRing(
                      progress: progress.clamp(0, 1),
                      size: 86,
                      strokeWidth: 8,
                      color: Colors.white,
                      trackColor: Colors.white.withValues(alpha: 0.18),
                      center: Text(
                        'Day ${workout.dayNumber}',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  workout.name,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  workout.focus,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 24),
                AtlasGradientButton(
                  label: 'Log in Train',
                  icon: Icons.play_arrow_rounded,
                  colors: [
                    Colors.white.withValues(alpha: 0.24),
                    Colors.white.withValues(alpha: 0.12),
                  ],
                  onPressed:
                      () => showAtlasSnack(
                        context,
                        message: 'Open Train to complete today\'s workout.',
                        icon: Icons.fitness_center_rounded,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingWorkoutGlyph extends StatelessWidget {
  const _FloatingWorkoutGlyph();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1600),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        final lift = 4 * (1 - (value - 0.5).abs() * 2);
        return Transform.translate(offset: Offset(0, -lift), child: child);
      },
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Icon(
          Icons.fitness_center_rounded,
          color: Colors.white,
          size: 27,
        ),
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final weight = snapshot.latestWeight;
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.02,
      ),
      children: [
        AtlasStatCard(
          label: 'Fitness Score',
          value: '${snapshot.fitnessScore}',
          caption: _scoreLabel(snapshot.fitnessScore),
          icon: Icons.speed_rounded,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'Weekly Progress',
          value: '${snapshot.completedThisWeek} / ${snapshot.weeklyTarget}',
          caption: 'workouts complete',
          icon: Icons.calendar_month_rounded,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'Weight',
          value:
              weight == null
                  ? 'Add today'
                  : '${weight.toStringAsFixed(1)} ${snapshot.latestWeightUnit}',
          caption: weight == null ? 'no weight logged' : 'latest entry',
          icon: Icons.monitor_weight_outlined,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'Hydration',
          value: '${snapshot.hydrationToday}',
          caption: 'water logs today',
          icon: Icons.water_drop_outlined,
          color: AtlasColors.warning,
        ),
      ],
    );
  }
}

class _ReadinessCard extends StatelessWidget {
  const _ReadinessCard({required this.snapshot});

  final AtlasDashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 142,
        child: Stack(
          children: [
            const Positioned.fill(child: _RecoveryWave()),
            Row(
              children: [
                AnimatedProgressRing(
                  progress: snapshot.recoveryScore / 100,
                  size: 82,
                  strokeWidth: 8,
                  color: AtlasColors.success,
                  center: Text(
                    '${snapshot.recoveryScore}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Readiness Insight'),
                      const SizedBox(height: 6),
                      Text(
                        'Based on this week\'s workouts and today\'s hydration logs.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard({required this.repository, required this.onSaved});

  final AtlasDataRepository? repository;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    final actions = [
      (
        Icons.monitor_weight_outlined,
        'Weight',
        () => _showWeightSheet(context),
      ),
      (Icons.mood_outlined, 'Mood', () => _showWellnessSheet(context)),
      (Icons.water_drop_outlined, 'Water', () => _saveWater(context)),
      (Icons.directions_run_rounded, 'Cardio', () => _showCardioSheet(context)),
      (
        Icons.sports_basketball_outlined,
        'Sport',
        () => _showSportSheet(context),
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
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final action in actions)
                AtlasPressable(
                  onTap: action.$3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AtlasColors.hairline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(action.$1, size: 19, color: AtlasColors.inkMuted),
                        const SizedBox(width: 9),
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

  Future<void> _showWeightSheet(BuildContext context) async {
    final controller = TextEditingController();
    final noteController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => _ActionSheet(
            title: 'Log Weight',
            children: [
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Weight kg'),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ],
            onSave: () async {
              final weight = double.tryParse(controller.text);
              if (weight == null || weight <= 0) {
                return;
              }
              await repository?.saveWeight(weight, note: noteController.text);
              onSaved();
              if (context.mounted) {
                Navigator.pop(context);
                showAtlasSnack(context, message: 'Weight saved.');
              }
            },
          ),
    );
  }

  Future<void> _showWellnessSheet(BuildContext context) async {
    var mood = 3.0;
    var energy = 3.0;
    var stress = 3.0;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => _ActionSheet(
                  title: 'Mood Check-in',
                  children: [
                    _SliderRow(
                      label: 'Mood',
                      value: mood,
                      onChanged: (value) => setSheetState(() => mood = value),
                    ),
                    _SliderRow(
                      label: 'Energy',
                      value: energy,
                      onChanged: (value) => setSheetState(() => energy = value),
                    ),
                    _SliderRow(
                      label: 'Stress',
                      value: stress,
                      onChanged: (value) => setSheetState(() => stress = value),
                    ),
                  ],
                  onSave: () async {
                    await repository?.saveWellness(
                      mood: mood.round(),
                      energy: energy.round(),
                      stress: stress.round(),
                    );
                    onSaved();
                    if (context.mounted) {
                      Navigator.pop(context);
                      showAtlasSnack(context, message: 'Wellness saved.');
                    }
                  },
                ),
          ),
    );
  }

  Future<void> _saveWater(BuildContext context) async {
    await repository?.saveHydration();
    onSaved();
    if (context.mounted) {
      showAtlasSnack(context, message: 'Water logged.');
    }
  }

  Future<void> _showCardioSheet(BuildContext context) async {
    await _durationSheet(
      context,
      title: 'Log Cardio',
      label: 'Activity',
      defaultName: 'Run',
      onSave:
          (name, minutes) => repository?.saveCardio(
            activityType: name,
            durationMinutes: minutes,
          ),
      message: 'Cardio saved.',
    );
  }

  Future<void> _showSportSheet(BuildContext context) async {
    await _durationSheet(
      context,
      title: 'Log Sport',
      label: 'Sport',
      defaultName: 'Basketball',
      onSave:
          (name, minutes) =>
              repository?.saveSport(sportName: name, durationMinutes: minutes),
      message: 'Sport saved.',
    );
  }

  Future<void> _durationSheet(
    BuildContext context, {
    required String title,
    required String label,
    required String defaultName,
    required Future<void>? Function(String name, int minutes) onSave,
    required String message,
  }) async {
    final nameController = TextEditingController(text: defaultName);
    final minutesController = TextEditingController(text: '30');
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => _ActionSheet(
            title: title,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: label),
              ),
              TextField(
                controller: minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Minutes'),
              ),
            ],
            onSave: () async {
              final minutes = int.tryParse(minutesController.text) ?? 0;
              if (minutes <= 0 || nameController.text.trim().isEmpty) {
                return;
              }
              await onSave(nameController.text.trim(), minutes);
              onSaved();
              if (context.mounted) {
                Navigator.pop(context);
                showAtlasSnack(context, message: message);
              }
            },
          ),
    );
  }
}

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.title,
    required this.children,
    required this.onSave,
  });

  final String title;
  final List<Widget> children;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        8,
        22,
        MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 16),
          ...children,
          const SizedBox(height: 22),
          AtlasGradientButton(
            label: 'Save',
            icon: Icons.check_rounded,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label ${value.round()}',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _RecoveryWave extends StatelessWidget {
  const _RecoveryWave();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1800),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return CustomPaint(
          painter: _WavePainter(value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              AtlasColors.success.withValues(alpha: 0.08),
              AtlasColors.accent.withValues(alpha: 0.05),
            ],
          ).createShader(Offset.zero & size);
    final path = Path()..moveTo(0, size.height * 0.62);
    for (var x = 0.0; x <= size.width; x += 8) {
      final y =
          size.height * 0.62 +
          10 * (1 - phase) +
          10 * (0.5 - (x / size.width - 0.5).abs());
      path.lineTo(x, y);
    }
    path
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

String _scoreLabel(int score) {
  if (score >= 80) {
    return 'strong';
  }
  if (score >= 60) {
    return 'building';
  }
  return 'starting';
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
