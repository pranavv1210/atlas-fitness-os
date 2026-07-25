import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/section_title.dart';
import '../../profile/domain/models/user_profile.dart';

class MeScreen extends StatelessWidget {
  const MeScreen({required this.profile, required this.onSignOut, super.key});

  final UserProfile profile;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Personal settings',
      title: 'Me',
      children: [
        _ProfileCard(profile: profile, onSignOut: onSignOut),
        const _WorkoutCycleCard(),
        _PreferenceCard(),
        const _AboutCard(),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile, required this.onSignOut});

  final UserProfile profile;
  final Future<void> Function() onSignOut;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      radius: 34,
      padding: const EdgeInsets.all(24),
      color: AtlasColors.ink,
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -22,
            child: Icon(
              Icons.blur_on_rounded,
              size: 132,
              color: Colors.white.withValues(alpha: 0.045),
            ),
          ),
          Row(
            children: [
              Container(
                width: 76,
                height: 76,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.22),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child:
                    profile.avatarUrl == null
                        ? Text(
                          _initial,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.displayName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: Colors.white, height: 1.05),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      profile.email,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.68),
                      ),
                    ),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: onSignOut,
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _initial {
    final source =
        profile.displayName.trim().isNotEmpty
            ? profile.displayName.trim()
            : profile.email.trim();
    if (source.isEmpty) {
      return 'P';
    }
    return source.characters.first.toUpperCase();
  }
}

class _WorkoutCycleCard extends StatelessWidget {
  const _WorkoutCycleCard();

  @override
  Widget build(BuildContext context) {
    const cycle = [
      ('Day 1', 'Chest + Triceps'),
      ('Day 2', 'Back + Biceps'),
      ('Day 3', 'Arms + Abs'),
      ('Day 4', 'Shoulders + Legs'),
      ('Day 5', 'Rest'),
    ];

    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Default Workout Cycle'),
          const SizedBox(height: 8),
          Text(
            'Planned routine from your Atlas setup. Completion data will appear only after workout logging exists.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final item in cycle) ...[
            Row(
              children: [
                SizedBox(
                  width: 54,
                  child: Text(
                    item.$1,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.$2,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (item != cycle.last) const SizedBox(height: 13),
          ],
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  const _PreferenceCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Preferences'),
          const SizedBox(height: 14),
          _PreferenceRow(
            icon: Icons.straighten_outlined,
            title: 'Units',
            value: 'Metric',
            onTap:
                () => showAtlasSnack(context, message: 'Metric units active.'),
          ),
          _PreferenceRow(
            icon: Icons.palette_outlined,
            title: 'Appearance',
            value: 'Light',
            onTap:
                () => showAtlasSnack(
                  context,
                  message: 'Light glass appearance active.',
                ),
          ),
          _PreferenceRow(
            icon: Icons.cloud_done_outlined,
            title: 'Sync',
            value: 'Configured',
            onTap:
                () => showAtlasSnack(
                  context,
                  message: 'Supabase configuration is present.',
                ),
          ),
          _PreferenceRow(
            icon: Icons.lock_outline,
            title: 'Privacy Lock',
            value: 'Off',
            showDivider: false,
            onTap:
                () => showAtlasSnack(context, message: 'Privacy lock is off.'),
          ),
        ],
      ),
    );
  }
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AtlasPressable(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AtlasColors.surfaceWarm,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AtlasColors.hairline),
                  ),
                  child: Icon(icon, size: 19, color: AtlasColors.inkMuted),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(width: 5),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AtlasColors.inkSoft,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: AtlasColors.hairline),
      ],
    );
  }
}

class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Atlas'),
          const SizedBox(height: 8),
          Text(
            'Your Personal Fitness Operating System',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Version', style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Text(
                '0.1.0 Prototype',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
