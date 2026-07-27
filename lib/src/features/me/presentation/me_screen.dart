import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
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

class _PreferenceCard extends StatefulWidget {
  const _PreferenceCard();

  @override
  State<_PreferenceCard> createState() => _PreferenceCardState();
}

class _PreferenceCardState extends State<_PreferenceCard> {
  bool _notifications = false;
  bool _privacyLock = false;
  int _hydrationIntervalMinutes = 60;
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.maybeRead(context);
    if (dependencies != null) {
      _notifications = dependencies.preferences.notificationEnabled;
      _privacyLock = dependencies.preferences.biometricEnabled;
      _hydrationIntervalMinutes =
          dependencies.preferences.hydrationIntervalMinutes;
      _themeMode = dependencies.themeMode.value;
    }
  }

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
            value: _themeModeLabel(_themeMode),
            onTap: _showAppearanceSheet,
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
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            value: _notifications ? 'On' : 'Off',
            onTap: _toggleNotifications,
          ),
          _PreferenceRow(
            icon: Icons.water_drop_outlined,
            title: 'Water interval',
            value: '$_hydrationIntervalMinutes min',
            onTap: _showHydrationIntervalSheet,
          ),
          _PreferenceRow(
            icon: Icons.fingerprint_rounded,
            title: 'Biometrics',
            value: _privacyLock ? 'On' : 'Off',
            showDivider: false,
            onTap: _togglePrivacyLock,
          ),
        ],
      ),
    );
  }

  Future<void> _toggleNotifications() async {
    final dependencies = AppScope.maybeRead(context);
    if (dependencies == null) return;
    if (_notifications) {
      await dependencies.notificationService.cancelAtlasReminders();
      await dependencies.preferences.setNotificationEnabled(false);
      setState(() => _notifications = false);
      if (mounted) {
        showAtlasSnack(context, message: 'Atlas reminders are off.');
      }
      return;
    }

    final granted = await dependencies.notificationService.requestPermission();
    await dependencies.preferences.setNotificationPrompted();
    await dependencies.preferences.setNotificationEnabled(granted);
    if (granted) {
      await dependencies.notificationService.scheduleAtlasReminders(
        hydrationIntervalMinutes:
            dependencies.preferences.hydrationIntervalMinutes,
      );
    }
    setState(() => _notifications = granted);
    if (mounted) {
      showAtlasSnack(
        context,
        message:
            granted
                ? 'Atlas reminders are on.'
                : 'Notifications are blocked in Android settings.',
      );
    }
  }

  Future<void> _showHydrationIntervalSheet() async {
    final dependencies = AppScope.maybeRead(context);
    if (dependencies == null) return;
    final selected = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              4,
              22,
              MediaQuery.viewInsetsOf(context).bottom +
                  MediaQuery.paddingOf(context).bottom +
                  22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Water interval'),
                const SizedBox(height: 8),
                Text(
                  'Atlas will send gentle hydration nudges between 8 AM and 10 PM.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                for (final minutes in [30, 60, 90, 120])
                  _HydrationIntervalOption(
                    minutes: minutes,
                    selected: minutes == _hydrationIntervalMinutes,
                    onTap: () => Navigator.pop(context, minutes),
                  ),
                _HydrationIntervalOption.custom(
                  minutes:
                      [30, 60, 90, 120].contains(_hydrationIntervalMinutes)
                          ? null
                          : _hydrationIntervalMinutes,
                  selected:
                      ![30, 60, 90, 120].contains(_hydrationIntervalMinutes),
                  onTap: () async {
                    final custom = await _showCustomHydrationIntervalSheet(
                      context,
                      _hydrationIntervalMinutes,
                    );
                    if (custom != null && context.mounted) {
                      Navigator.pop(context, custom);
                    }
                  },
                ),
              ],
            ),
          ),
    );
    if (selected == null) return;

    if (mounted) {
      setState(() => _hydrationIntervalMinutes = selected);
    }
    await dependencies.preferences.setHydrationIntervalMinutes(selected);
    var notificationsEnabled = dependencies.preferences.notificationEnabled;
    if (!notificationsEnabled) {
      final granted =
          await dependencies.notificationService.requestPermission();
      await dependencies.preferences.setNotificationPrompted();
      await dependencies.preferences.setNotificationEnabled(granted);
      notificationsEnabled = granted;
      if (mounted) {
        setState(() => _notifications = granted);
      }
    }
    if (notificationsEnabled) {
      await dependencies.notificationService.scheduleAtlasReminders(
        hydrationIntervalMinutes: selected,
      );
    }
    if (mounted) {
      showAtlasSnack(
        context,
        message:
            notificationsEnabled
                ? 'Water reminders set to every $selected minutes.'
                : 'Notifications are blocked in Android settings.',
        icon: Icons.water_drop_outlined,
      );
    }
  }

  Future<int?> _showCustomHydrationIntervalSheet(
    BuildContext context,
    int currentMinutes,
  ) async {
    final controller = TextEditingController(
      text:
          [30, 60, 90, 120].contains(currentMinutes)
              ? ''
              : currentMinutes.toString(),
    );
    String? error;
    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    4,
                    22,
                    MediaQuery.viewInsetsOf(context).bottom +
                        MediaQuery.paddingOf(context).bottom +
                        22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Custom interval'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        decoration: InputDecoration(
                          labelText: 'Minutes',
                          helperText: 'Enter 10 to 360 minutes.',
                          errorText: error,
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surface,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            final value = int.tryParse(controller.text.trim());
                            if (value == null || value < 10 || value > 360) {
                              setSheetState(() {
                                error = 'Use a value from 10 to 360.';
                              });
                              return;
                            }
                            Navigator.pop(context, value);
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Save Custom'),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showAppearanceSheet() async {
    final dependencies = AppScope.maybeRead(context);
    if (dependencies == null) return;
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              4,
              22,
              MediaQuery.paddingOf(context).bottom + 22,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Appearance'),
                const SizedBox(height: 12),
                for (final mode in [
                  ThemeMode.system,
                  ThemeMode.light,
                  ThemeMode.dark,
                ])
                  _AppearanceOption(
                    mode: mode,
                    selected: mode == _themeMode,
                    onTap: () => Navigator.pop(context, mode),
                  ),
              ],
            ),
          ),
    );
    if (selected == null) return;
    await dependencies.setThemeMode(selected);
    if (mounted) {
      setState(() => _themeMode = selected);
      showAtlasSnack(
        context,
        message: '${_themeModeLabel(selected)} mode active.',
      );
    }
  }

  Future<void> _togglePrivacyLock() async {
    final dependencies = AppScope.maybeRead(context);
    if (dependencies == null) return;
    if (_privacyLock) {
      await dependencies.preferences.setBiometricEnabled(false);
      setState(() => _privacyLock = false);
      if (mounted) {
        showAtlasSnack(context, message: 'Biometrics are off.');
      }
      return;
    }

    final available = await dependencies.biometricService.isAvailable();
    if (!available) {
      if (mounted) {
        showAtlasSnack(
          context,
          message: 'Biometrics are not available on this device.',
          icon: Icons.fingerprint_rounded,
        );
      }
      return;
    }
    final authenticated = await dependencies.biometricService.authenticate();
    if (!authenticated) return;
    await dependencies.preferences.setBiometricEnabled(true);
    setState(() => _privacyLock = true);
    if (mounted) {
      showAtlasSnack(context, message: 'Biometric lock is on.');
    }
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? AtlasColors.accent.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                selected
                    ? AtlasColors.accent.withValues(alpha: 0.22)
                    : AtlasColors.hairline,
          ),
        ),
        child: Row(
          children: [
            Icon(_themeModeIcon(mode), color: AtlasColors.accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _themeModeLabel(mode),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AtlasColors.accent : AtlasColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _HydrationIntervalOption extends StatelessWidget {
  const _HydrationIntervalOption({
    required this.minutes,
    required this.selected,
    required this.onTap,
  }) : custom = false;

  const _HydrationIntervalOption.custom({
    required this.minutes,
    required this.selected,
    required this.onTap,
  }) : custom = true;

  final int? minutes;
  final bool selected;
  final VoidCallback onTap;
  final bool custom;

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? AtlasColors.accent.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color:
                selected
                    ? AtlasColors.accent.withValues(alpha: 0.22)
                    : AtlasColors.hairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AtlasColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.water_drop_outlined,
                color: AtlasColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                custom
                    ? minutes == null
                        ? 'Custom'
                        : 'Custom ($minutes min)'
                    : 'Every $minutes minutes',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AtlasColors.accent : AtlasColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

String _themeModeLabel(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => 'Light',
    ThemeMode.dark => 'Dark',
    ThemeMode.system => 'System',
  };
}

IconData _themeModeIcon(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => Icons.light_mode_outlined,
    ThemeMode.dark => Icons.dark_mode_outlined,
    ThemeMode.system => Icons.brightness_auto_outlined,
  };
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
              Text('1.0.0', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ],
      ),
    );
  }
}
