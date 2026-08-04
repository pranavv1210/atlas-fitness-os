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
import '../../atlas/presentation/atlas_log_sheets.dart';
import '../../profile/domain/models/user_profile.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({
    required this.profile,
    required this.onOpenTrain,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onOpenTrain;

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
    return _repository?.loadSnapshot() ?? emptyAtlasSnapshot();
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
        final data = snapshot.data ?? emptyAtlasSnapshot();
        return AtlasAppFrame(
          subtitle: '',
          title: '${_greeting(DateTime.now())} $firstName',
          titleStyle: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontSize: 31,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
          trailing: _StatusPill(
            text: '${data.completedThisWeek}/${data.weeklyTarget} week',
          ),
          children: [
            _FocusCard(snapshot: data),
            _MissionCard(snapshot: data, onOpenTrain: widget.onOpenTrain),
            _MetricsGrid(snapshot: data),
            if (data.recoveryScore == null)
              const _EmptyInsightCard()
            else
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
    final quote = _quoteOfTheDay();
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Focus', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            quote,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              height: 1.22,
            ),
          ),
        ],
      ),
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({required this.snapshot, required this.onOpenTrain});

  final AtlasDashboardSnapshot snapshot;
  final VoidCallback onOpenTrain;

  @override
  Widget build(BuildContext context) {
    final workout = snapshot.todayWorkout;
    if (workout == null) {
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
                  const _FloatingWorkoutGlyph(),
                  const SizedBox(height: 34),
                  Text(
                    'Start your journey',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Your workout cycle begins only after you save your first real session.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AtlasGradientButton(
                    label: 'Start in Train',
                    icon: Icons.play_arrow_rounded,
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.12),
                    ],
                    onPressed: onOpenTrain,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
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
                  onPressed: onOpenTrain,
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
          value: snapshot.fitnessScore?.toString() ?? 'No score',
          caption:
              snapshot.fitnessScore == null
                  ? 'log activity first'
                  : 'from logs',
          icon: Icons.speed_rounded,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'Workout Streak',
          value: '${snapshot.currentStreak}',
          caption:
              snapshot.currentStreak == 1
                  ? 'workout active'
                  : snapshot.currentStreak == 0
                  ? 'start today'
                  : 'workouts active',
          icon: Icons.local_fire_department_rounded,
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
                  progress: (snapshot.recoveryScore ?? 0) / 100,
                  size: 82,
                  strokeWidth: 8,
                  color: AtlasColors.success,
                  center: Text(
                    '${snapshot.recoveryScore ?? 0}',
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

class _EmptyInsightCard extends StatelessWidget {
  const _EmptyInsightCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AtlasColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AtlasColors.success,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Readiness will appear after Atlas has workout and hydration logs from you.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
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
    final saved = await showAtlasWeightLogSheet(
      context,
      repository: repository,
    );
    if (saved) {
      onSaved();
      if (context.mounted) showAtlasSnack(context, message: 'Weight saved.');
    }
  }

  Future<void> _saveWater(BuildContext context) async {
    await repository?.saveHydration();
    onSaved();
    if (context.mounted) {
      showAtlasSnack(context, message: 'Water logged.');
    }
  }

  Future<void> _showCardioSheet(BuildContext context) async {
    final saved = await showAtlasCardioLogSheet(
      context,
      repository: repository,
    );
    if (saved) {
      onSaved();
      if (context.mounted) showAtlasSnack(context, message: 'Cardio saved.');
    }
  }

  Future<void> _showSportSheet(BuildContext context) async {
    final saved = await showAtlasSportLogSheet(context, repository: repository);
    if (saved) {
      onSaved();
      if (context.mounted) showAtlasSnack(context, message: 'Sport saved.');
    }
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

String _quoteOfTheDay() {
  const quotes = [
    '\u2728 Small progress every day becomes extraordinary.',
    '\u{1F525} Discipline builds freedom.',
    '\u{1F4AA} Earn your tomorrow.',
    '\u{1F33F} Calm effort compounds.',
    '\u26A1 One focused rep changes the day.',
  ];
  final now = DateTime.now();
  return quotes[DateTime(now.year, now.month, now.day).day % quotes.length];
}

AtlasDashboardSnapshot emptyAtlasSnapshot() {
  return AtlasDashboardSnapshot(
    todayWorkout: null,
    starterWorkout: fallbackCycle.first,
    templateExercises: const [],
    exerciseLibrary: fallbackExercises,
    completedThisWeek: 0,
    weeklyTarget: 5,
    totalWorkouts: 0,
    monthWorkouts: 0,
    completedToday: false,
    cycleStarted: false,
    currentStreak: 0,
    hydrationToday: 0,
    activeGoals: const [],
    todayReport: null,
  );
}
