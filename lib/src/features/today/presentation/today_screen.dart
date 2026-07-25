import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/atlas_stat_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../profile/domain/models/user_profile.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final firstName = _firstName(profile);

    return AtlasAppFrame(
      subtitle: '${_greeting(DateTime.now())} $firstName',
      title: 'Today',
      trailing: const _SetupPill(),
      children: [
        const _FreshInstallCard(),
        const _MissionEmptyCard(),
        const _NewAccountGrid(),
        const _ReadinessEmptyCard(),
        const _QuickActionsCard(),
      ],
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

class _SetupPill extends StatelessWidget {
  const _SetupPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AtlasColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AtlasColors.accent.withValues(alpha: 0.16)),
      ),
      child: Text(
        'New setup',
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AtlasColors.accent),
      ),
    );
  }
}

class _FreshInstallCard extends StatelessWidget {
  const _FreshInstallCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Focus', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          Text(
            'Atlas is ready. Your dashboard will build from the data you log.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ],
      ),
    );
  }
}

class _MissionEmptyCard extends StatelessWidget {
  const _MissionEmptyCard();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.accent.withValues(alpha: 0.16 * value),
                blurRadius: 34 + 10 * value,
                offset: const Offset(0, 22),
              ),
            ],
          ),
          child: child,
        );
      },
      child: ClipRRect(
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
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                  borderRadius: BorderRadius.circular(34),
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
                        progress: 0,
                        size: 86,
                        strokeWidth: 8,
                        color: Colors.white,
                        trackColor: Colors.white.withValues(alpha: 0.18),
                        semanticLabel: 'No workout progress logged yet',
                        center: Text(
                          'Ready',
                          style: Theme.of(
                            context,
                          ).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'No workout data yet',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Today\'s workout will be calculated from your real history once workout logging is built.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AtlasGradientButton(
                    label: 'Workout logging coming soon',
                    icon: Icons.lock_clock_rounded,
                    colors: [
                      Colors.white.withValues(alpha: 0.24),
                      Colors.white.withValues(alpha: 0.12),
                    ],
                    onPressed:
                        () => showAtlasSnack(
                          context,
                          message:
                              'Workout logging is coming soon. No data was saved.',
                          icon: Icons.info_outline_rounded,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
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
      ),
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

class _NewAccountGrid extends StatelessWidget {
  const _NewAccountGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.02,
      ),
      children: const [
        AtlasStatCard(
          label: 'Fitness Score',
          value: 'No data yet',
          caption: 'calculated later',
          icon: Icons.speed_rounded,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'Weekly Progress',
          value: 'No data yet',
          caption: 'workouts logged',
          icon: Icons.calendar_month_rounded,
          color: AtlasColors.success,
        ),
        AtlasStatCard(
          label: 'Weight',
          value: 'No data yet',
          caption: 'first entry pending',
          icon: Icons.monitor_weight_outlined,
          color: AtlasColors.accent,
        ),
        AtlasStatCard(
          label: 'Hydration',
          value: 'No data yet',
          caption: 'nudges not enabled',
          icon: Icons.water_drop_outlined,
          color: AtlasColors.warning,
        ),
      ],
    );
  }
}

class _ReadinessEmptyCard extends StatelessWidget {
  const _ReadinessEmptyCard();

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
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AtlasColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.favorite_border_rounded,
                    color: AtlasColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Readiness Insight'),
                      const SizedBox(height: 6),
                      Text(
                        'Recovery, energy, and stress will appear after you start logging wellness inputs.',
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
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) {
    final actions = [
      (Icons.monitor_weight_outlined, 'Log Weight'),
      (Icons.mood_outlined, 'Mood'),
      (Icons.water_drop_outlined, 'Water'),
      (Icons.directions_run_rounded, 'Cardio'),
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
                  onTap:
                      () => showAtlasSnack(
                        context,
                        message:
                            '${action.$2} is coming soon. No data was saved.',
                        icon: Icons.info_outline_rounded,
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
}
