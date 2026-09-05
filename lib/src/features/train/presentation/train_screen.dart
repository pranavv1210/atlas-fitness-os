import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/section_title.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';
import '../../today/presentation/today_screen.dart';

class TrainScreen extends StatefulWidget {
  const TrainScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  Future<AtlasDashboardSnapshot>? _future;
  AtlasDataRepository? _repository;
  AppDependencies? _dependencies;
  List<_CustomWorkoutPlanDay> _customPlan = _defaultCustomPlan();
  final List<_EditableWorkoutEntry> _entries = [];
  ValueNotifier<int>? _draftVersionNotifier;
  int? _sessionDayOverrideNumber;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dependencies = AppScope.maybeRead(context);
    _repository = _dependencies?.atlasDataRepository;
    final nextNotifier = _dependencies?.workoutDraftVersion;
    if (_draftVersionNotifier != nextNotifier) {
      _draftVersionNotifier?.removeListener(_handleExternalDraftChanged);
      _draftVersionNotifier = nextNotifier;
      _draftVersionNotifier?.addListener(_handleExternalDraftChanged);
    }
    _future ??= _load();
  }

  @override
  void dispose() {
    _draftVersionNotifier?.removeListener(_handleExternalDraftChanged);
    super.dispose();
  }

  void _handleExternalDraftChanged() {
    if (!mounted) return;
    setState(() {
      _future = _load();
    });
  }

  Future<AtlasDashboardSnapshot> _load() async {
    final snapshot =
        _repository == null
            ? emptyAtlasSnapshot()
            : await _repository!.loadSnapshot();
    _customPlan = _loadCustomWorkoutPlan(
      _dependencies?.preferences.customWorkoutPlan ?? const [],
      snapshot.exerciseLibrary,
    );
    final effectiveSnapshot = _applyCustomWorkoutPlan(snapshot, _customPlan);
    _entries.clear();
    if (effectiveSnapshot.completedToday) {
      _sessionDayOverrideNumber = null;
      await _clearDraft();
      return effectiveSnapshot;
    }
    final activeWorkout = _activeWorkoutFor(effectiveSnapshot);
    final restored = _restoreDraft(
      activeWorkout,
      effectiveSnapshot.exerciseLibrary,
    );
    if (restored) {
      return effectiveSnapshot;
    }
    final plannedDay =
        activeWorkout == null
            ? null
            : _customPlan[activeWorkout.dayNumber.clamp(1, 5) - 1];
    if (plannedDay != null && !plannedDay.isRestDay) {
      _entries.addAll([
        for (final exercise in plannedDay.exercises)
          _EditableWorkoutEntry(exercise),
      ]);
    }
    return effectiveSnapshot;
  }

  Future<void> _saveWorkout(AtlasDashboardSnapshot snapshot) async {
    if (_saving) return;
    final repository = _repository;
    final workout = _activeWorkoutFor(snapshot);
    if (repository == null || workout == null) {
      showAtlasSnack(
        context,
        message: 'Sign in and choose at least one exercise before saving.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }
    if (_entries.isEmpty) {
      showAtlasSnack(
        context,
        message: 'Add an exercise before saving your workout.',
        icon: Icons.add_rounded,
      );
      return;
    }
    if (snapshot.completedToday) {
      showAtlasSnack(
        context,
        message: 'Today\'s workout is already saved.',
        icon: Icons.check_circle_outline_rounded,
      );
      return;
    }
    setState(() => _saving = true);
    final confirmed = await _confirmSaveWorkout(workout.name, _entries.length);
    if (!confirmed || !mounted) {
      if (mounted) setState(() => _saving = false);
      return;
    }

    try {
      await repository.saveWorkout(
        day: workout,
        entries: [
          for (final entry in _entries)
            AtlasWorkoutEntry(
              exercise: entry.exercise,
              sets: _isCardioStyleExercise(entry.exercise) ? 1 : entry.sets,
              reps: entry.reps,
              weight: entry.weight,
              setLogs: [
                if (_isCardioStyleExercise(entry.exercise))
                  AtlasWorkoutSetDraft(
                    setNumber: 1,
                    reps: entry.reps,
                    weight: entry.weight,
                  )
                else
                  for (final set in entry.setRows)
                    AtlasWorkoutSetDraft(
                      setNumber: set.setNumber,
                      reps: set.reps,
                      weight: set.weight,
                    ),
              ],
            ),
        ],
      );
      if (!mounted) return;
      unawaited(_clearDraft());
      unawaited(_clearSelectedWorkout());
      _sessionDayOverrideNumber = null;
      unawaited(
        _dependencies?.notificationService.showWorkoutCompletedMotivation(
          workoutName: workout.name,
        ),
      );
      showCompletionCelebration(context);
      setState(() => _future = _load());
    } on AtlasWorkoutAlreadySavedException {
      if (!mounted) return;
      showAtlasSnack(
        context,
        message: 'Today\'s workout is already saved.',
        icon: Icons.check_circle_outline_rounded,
      );
      setState(() => _future = _load());
    } catch (_) {
      if (!mounted) return;
      showAtlasSnack(
        context,
        message: 'Workout could not be saved. Check Supabase and connection.',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool> _confirmSaveWorkout(
    String workoutName,
    int exerciseCount,
  ) async {
    return await showGeneralDialog<bool>(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Cancel save',
          barrierColor: Colors.black.withValues(alpha: 0.22),
          transitionDuration: const Duration(milliseconds: 200),
          pageBuilder:
              (context, animation, secondaryAnimation) => Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width - 48,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AtlasColors.hairline),
                      boxShadow: [
                        BoxShadow(
                          color: AtlasColors.ink.withValues(alpha: 0.12),
                          blurRadius: 26,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AtlasColors.accentSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: AtlasColors.accent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Save today\'s workout?',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$workoutName - $exerciseCount exercise${exerciseCount == 1 ? '' : 's'} - Workout History',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AtlasColors.inkMuted),
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => Navigator.pop(context, true),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size.fromHeight(52),
                                  backgroundColor: AtlasColors.ink,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          transitionBuilder:
              (context, animation, secondaryAnimation, child) =>
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                    child: FadeTransition(opacity: animation, child: child),
                  ),
        ) ??
        false;
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
        final activeWorkout = _activeWorkoutFor(data);
        return AtlasAppFrame(
          subtitle: '',
          title: 'Train',
          onBack: widget.onBack,
          children: [
            _WorkoutHero(
              snapshot: data,
              sessionWorkout: activeWorkout,
              saving: _saving,
              onSave: () => _saveWorkout(data),
              onChooseWorkout: () => _showSessionWorkoutChooser(data),
              onEditPlan: () => _showPlanEditor(data.exerciseLibrary),
            ),
            _ExerciseLogger(
              library: data.exerciseLibrary,
              entries: _entries,
              completedReport: data.todayReport,
              saving: _saving,
              onChanged: () => _handleEntriesChanged(data),
              onSave: () => _saveWorkout(data),
              onAdd:
                  data.completedToday || data.exerciseLibrary.isEmpty
                      ? null
                      : () async {
                        final picked = await showExercisePickerSheet(
                          context,
                          library: data.exerciseLibrary,
                          selected: _entries.lastOrNull?.exercise,
                        );
                        if (picked == null) return;
                        HapticFeedback.selectionClick();
                        setState(() {
                          _entries.add(_EditableWorkoutEntry(picked));
                        });
                        await _saveDraft(data);
                      },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPlanEditor(List<AtlasExercise> library) async {
    await _showWorkoutPlanEditorSheet(
      context,
      library: library,
      initialPlan: _customPlan,
      onChanged: (plan) async {
        await _persistWorkoutPlan(plan);
        if (!mounted) return;
        setState(() {
          _customPlan = plan;
          if (_sessionDayOverrideNumber != null &&
              _sessionDayOverrideNumber! > _customPlan.length) {
            _sessionDayOverrideNumber = _customPlan.length;
          }
          _future = _load();
        });
      },
    );
  }

  Future<void> _persistWorkoutPlan(List<_CustomWorkoutPlanDay> plan) async {
    await _dependencies?.preferences.setCustomWorkoutPlan([
      for (var index = 0; index < plan.length; index++)
        plan[index].copyWith(dayNumber: index + 1).toJson(),
    ]);
    if (!mounted) return;
    HapticFeedback.selectionClick();
  }

  Future<void> _showSessionWorkoutChooser(
    AtlasDashboardSnapshot snapshot,
  ) async {
    final activeWorkout = _activeWorkoutFor(snapshot);
    final selected = await showModalBottomSheet<int>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              22,
              4,
              22,
              MediaQuery.paddingOf(context).bottom + 18,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Log Which Workout?'),
                const SizedBox(height: 8),
                Text(
                  'Choose the workout you actually performed. Atlas will save the report with this title and keep the cycle moving after save.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                for (final day in _customPlan)
                  _SessionWorkoutOption(
                    day: day,
                    selected: activeWorkout?.dayNumber == day.dayNumber,
                    onTap: () => Navigator.pop(context, day.dayNumber),
                  ),
              ],
            ),
          ),
    );
    if (selected == null || !mounted) return;
    await _persistSelectedWorkout(selected);
    final day = _customPlan[selected.clamp(1, _customPlan.length) - 1];
    setState(() {
      _sessionDayOverrideNumber = selected;
      _entries
        ..clear()
        ..addAll([
          if (!day.isRestDay)
            for (final exercise in day.exercises)
              _EditableWorkoutEntry(exercise),
        ]);
    });
    await _saveDraft(snapshot);
    final draftVersion = _dependencies?.workoutDraftVersion;
    if (draftVersion != null) draftVersion.value += 1;
  }

  void _handleEntriesChanged(AtlasDashboardSnapshot snapshot) {
    setState(() {});
    _saveDraft(snapshot);
  }

  bool _restoreDraft(AtlasWorkoutDay? workout, List<AtlasExercise> library) {
    final userId = _repository?.currentUserId;
    final draft =
        userId == null
            ? null
            : _dependencies?.preferences.workoutDraftFor(userId);
    if (draft == null || workout == null) return false;
    if (draft['dayNumber'] != workout.dayNumber) return false;
    final rawEntries = draft['entries'];
    if (rawEntries is! List) return false;
    final byId = {for (final exercise in library) exercise.id: exercise};
    final restored = <_EditableWorkoutEntry>[];
    for (final rawEntry in rawEntries) {
      if (rawEntry is! Map) continue;
      final exerciseId = rawEntry['exerciseId'];
      if (exerciseId is! String) continue;
      final exercise = byId[exerciseId];
      if (exercise == null) continue;
      restored.add(
        _EditableWorkoutEntry.fromDraft(
          exercise,
          sets: rawEntry['sets'],
          reps: rawEntry['reps'],
          weight: rawEntry['weight'],
          setRows: rawEntry['setRows'],
        ),
      );
    }
    if (restored.isEmpty) return false;
    _entries.addAll(restored);
    return true;
  }

  Future<void> _saveDraft(AtlasDashboardSnapshot snapshot) async {
    final userId = _repository?.currentUserId;
    final workout = _activeWorkoutFor(snapshot);
    final preferences = _dependencies?.preferences;
    if (userId == null || preferences == null || workout == null) return;
    if (snapshot.completedToday || _entries.isEmpty) {
      await preferences.clearWorkoutDraft(userId);
      return;
    }
    await preferences.setWorkoutDraft(userId, {
      'dayNumber': workout.dayNumber,
      'workoutName': workout.name,
      'savedAt': DateTime.now().toIso8601String(),
      'entries': [
        for (final entry in _entries)
          {
            'exerciseId': entry.exercise.id,
            'sets': entry.sets,
            'reps': entry.reps,
            'weight': entry.weight,
            'setRows': [
              for (final set in entry.setRows)
                {
                  'setNumber': set.setNumber,
                  'reps': set.reps,
                  'weight': set.weight,
                },
            ],
          },
      ],
    });
  }

  Future<void> _clearDraft() async {
    final userId = _repository?.currentUserId;
    if (userId == null) return;
    await _dependencies?.preferences.clearWorkoutDraft(userId);
  }

  Future<void> _persistSelectedWorkout(int dayNumber) async {
    final userId = _repository?.currentUserId;
    final preferences = _dependencies?.preferences;
    if (userId == null || preferences == null) return;
    await preferences.setSelectedWorkoutDay(
      userId,
      _dateKey(DateTime.now()),
      dayNumber,
    );
  }

  Future<void> _clearSelectedWorkout() async {
    final userId = _repository?.currentUserId;
    if (userId == null) return;
    await _dependencies?.preferences.clearSelectedWorkoutDay(userId);
  }

  AtlasWorkoutDay? _activeWorkoutFor(AtlasDashboardSnapshot snapshot) {
    final base = snapshot.todayWorkout ?? snapshot.starterWorkout;
    final override = _sessionDayOverrideNumber;
    if (override == null) return base;
    final index = override.clamp(1, _customPlan.length) - 1;
    return _workoutFromPlanDay(_customPlan[index], base: base);
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({
    required this.snapshot,
    required this.sessionWorkout,
    required this.saving,
    required this.onSave,
    required this.onChooseWorkout,
    required this.onEditPlan,
  });

  final AtlasDashboardSnapshot snapshot;
  final AtlasWorkoutDay? sessionWorkout;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onChooseWorkout;
  final VoidCallback onEditPlan;

  @override
  Widget build(BuildContext context) {
    final plannedWorkout = snapshot.todayWorkout ?? snapshot.starterWorkout;
    final workout = sessionWorkout ?? plannedWorkout;
    final hasSessionOverride =
        plannedWorkout != null &&
        workout != null &&
        plannedWorkout.dayNumber != workout.dayNumber;
    final isFirst = !snapshot.hasWorkoutCycleStarted;
    final savedToday = snapshot.completedToday;
    final report = snapshot.todayReport;
    final totalSets = snapshot.templateExercises.fold<int>(
      0,
      (sum, item) => sum + item.targetSets,
    );

    return AtlasCard(
      isGlass: true,
      radius: 28,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _WorkoutDayGlyph(workout: workout, size: 50),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      savedToday
                          ? 'Completed today'
                          : isFirst
                          ? 'First workout'
                          : 'Today\'s workout',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AtlasColors.inkMuted,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report?.title ?? workout?.name ?? 'Choose your workout',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        height: 1.02,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                onPressed: onChooseWorkout,
                icon: const Icon(Icons.swap_horiz_rounded),
                tooltip: 'Choose workout for this log',
              ),
              const SizedBox(width: 6),
              IconButton.filledTonal(
                onPressed: onEditPlan,
                icon: const Icon(Icons.edit_calendar_rounded),
                tooltip: 'Edit workout plan',
              ),
            ],
          ),
          if (!savedToday) ...[
            const SizedBox(height: 7),
            Text(
              hasSessionOverride
                  ? 'Manual log selection. Save this session, then the cycle continues with the next workout.'
                  : isFirst
                  ? 'Save this session to start Atlas.'
                  : workout?.focus ?? 'Log clean sets, reps, weight, and rest.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _HeroChip(
                  label:
                      savedToday
                          ? '${report?.totalExercises ?? 0} exercise${(report?.totalExercises ?? 0) == 1 ? '' : 's'}'
                          : '${snapshot.templateExercises.length} moves',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroChip(
                  label:
                      savedToday
                          ? _reportLoadChip(report)
                          : totalSets == 0
                          ? 'Custom builder'
                          : '$totalSets target sets',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AtlasColors.hairline,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 13),
      ),
    );
  }
}

class _WorkoutDayGlyph extends StatelessWidget {
  const _WorkoutDayGlyph({required this.workout, required this.size});

  final AtlasWorkoutDay? workout;
  final double size;

  @override
  Widget build(BuildContext context) {
    final icon = _workoutDayIcon(workout);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AtlasColors.accent, AtlasColors.lilac],
        ),
        borderRadius: BorderRadius.circular(size * 0.34),
        boxShadow: [
          BoxShadow(
            color: AtlasColors.accent.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: size * 0.42),
    );
  }
}

IconData _workoutDayIcon(AtlasWorkoutDay? workout) {
  final text = '${workout?.name ?? ''} ${workout?.focus ?? ''}'.toLowerCase();
  if (workout?.isRestDay == true ||
      text.contains('rest') ||
      text.contains('recovery')) {
    return Icons.self_improvement_rounded;
  }
  if (text.contains('leg')) return Icons.directions_run_rounded;
  if (text.contains('abs') || text.contains('core')) {
    return Icons.all_inclusive_rounded;
  }
  return Icons.fitness_center_rounded;
}

class _ExerciseLogger extends StatelessWidget {
  const _ExerciseLogger({
    required this.library,
    required this.entries,
    required this.completedReport,
    required this.saving,
    required this.onChanged,
    required this.onAdd,
    required this.onSave,
  });

  final List<AtlasExercise> library;
  final List<_EditableWorkoutEntry> entries;
  final AtlasWorkoutReport? completedReport;
  final bool saving;
  final VoidCallback onChanged;
  final VoidCallback? onAdd;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [const SectionTitle('Exercises')]),
        const SizedBox(height: 12),
        if (completedReport != null)
          _CompletedWorkoutExerciseList(report: completedReport!)
        else if (entries.isEmpty)
          Column(
            children: [
              const _EmptyExerciseCard(),
              const SizedBox(height: 12),
              _BottomAddExerciseButton(onPressed: onAdd),
            ],
          )
        else
          for (var index = 0; index < entries.length; index++) ...[
            _ExerciseEditor(
              index: index + 1,
              entry: entries[index],
              library: library,
              onChanged: onChanged,
              onDelete: () {
                entries.removeAt(index);
                onChanged();
              },
            ),
            if (index != entries.length - 1) const SizedBox(height: 14),
            if (index == entries.length - 1) ...[
              const SizedBox(height: 12),
              _ExerciseFooterActions(
                saving: saving,
                onAdd: onAdd,
                onSave: onSave,
              ),
            ],
          ],
      ],
    );
  }
}

class _ExerciseFooterActions extends StatelessWidget {
  const _ExerciseFooterActions({
    required this.saving,
    required this.onAdd,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback? onAdd;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _BottomAddExerciseButton(onPressed: onAdd),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: AtlasGradientButton(
            label: saving ? 'Saving Workout' : 'Complete Workout',
            icon: saving ? Icons.sync_rounded : Icons.check_rounded,
            colors:
                Theme.of(context).brightness == Brightness.dark
                    ? const [Color(0xFF24324A), Color(0xFF4F7CD8)]
                    : const [Color(0xFF1E3A5F), Color(0xFF5E86D9)],
            minHeight: 70,
            borderRadius: 25,
            padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
            onPressed: saving ? null : onSave,
          ),
        ),
      ],
    );
  }
}

class _BottomAddExerciseButton extends StatelessWidget {
  const _BottomAddExerciseButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color:
                  isDark
                      ? AtlasColors.accent.withValues(alpha: 0.28)
                      : AtlasColors.ink.withValues(alpha: 0.08),
              blurRadius: isDark ? 26 : 16,
              spreadRadius: isDark ? -4 : -8,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: OutlinedButton.icon(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(58),
            backgroundColor:
                isDark
                    ? AtlasColors.accent.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.82),
            side: BorderSide(
              color:
                  isDark
                      ? AtlasColors.accent.withValues(alpha: 0.34)
                      : AtlasColors.hairline,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Add Exercise'),
        ),
      ),
    );
  }
}

class _EmptyExerciseCard extends StatelessWidget {
  const _EmptyExerciseCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(22),
      child: Text(
        'Tap Add to choose your first exercise. Atlas will save exactly what you build.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

Future<void> _showWorkoutPlanEditorSheet(
  BuildContext context, {
  required List<AtlasExercise> library,
  required List<_CustomWorkoutPlanDay> initialPlan,
  required Future<void> Function(List<_CustomWorkoutPlanDay> plan) onChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => _WorkoutPlanEditorSheet(
          library: library,
          initialPlan: initialPlan,
          onChanged: onChanged,
        ),
  );
}

class _WorkoutPlanEditorSheet extends StatefulWidget {
  const _WorkoutPlanEditorSheet({
    required this.library,
    required this.initialPlan,
    required this.onChanged,
  });

  final List<AtlasExercise> library;
  final List<_CustomWorkoutPlanDay> initialPlan;
  final Future<void> Function(List<_CustomWorkoutPlanDay> plan) onChanged;

  @override
  State<_WorkoutPlanEditorSheet> createState() =>
      _WorkoutPlanEditorSheetState();
}

class _WorkoutPlanEditorSheetState extends State<_WorkoutPlanEditorSheet> {
  late final List<_CustomWorkoutPlanDay> _plan;
  int _selectedDay = 0;

  @override
  void initState() {
    super.initState();
    _plan = [for (final day in widget.initialPlan) day.copy()];
  }

  @override
  Widget build(BuildContext context) {
    final day = _plan[_selectedDay];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.86,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionTitle('Workout Plan')),
                TextButton.icon(
                  onPressed: _addDay,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add day'),
                ),
              ],
            ),
            Text(
              'Auto-saved as you edit. Delete or add days to match your cycle.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _plan.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ChoiceChip(
                    label: Text('Day ${index + 1}'),
                    selected: _selectedDay == index,
                    onSelected: (_) => setState(() => _selectedDay = index),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              key: ValueKey('plan-name-${day.dayNumber}'),
              initialValue: day.name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Workout day name',
                prefixIcon: Icon(Icons.edit_rounded),
              ),
              onChanged: (value) {
                day.name = value.trim();
                _commit();
              },
              onFieldSubmitted: (_) => _commit(),
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
                _commit();
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: day.isRestDay,
              onChanged:
                  (value) => setState(() {
                    day.isRestDay = value;
                    if (value) day.exercises.clear();
                    _commit();
                  }),
              title: Text(
                'Rest day',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Exercises',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (_plan.length > 1)
                  TextButton.icon(
                    onPressed: _deleteSelectedDay,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete day'),
                  ),
                TextButton.icon(
                  onPressed: day.isRestDay ? null : _addExercise,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child:
                  day.isRestDay
                      ? const _PlanEmptyState(
                        message: 'This day is marked as recovery.',
                      )
                      : day.exercises.isEmpty
                      ? const _PlanEmptyState(
                        message: 'Add exercises for this day.',
                      )
                      : ListView.separated(
                        shrinkWrap: true,
                        itemCount: day.exercises.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final exercise = day.exercises[index];
                          return _PlanExerciseTile(
                            exercise: exercise,
                            canMoveUp: index > 0,
                            canMoveDown: index < day.exercises.length - 1,
                            onMoveUp: () => _moveExercise(index, -1),
                            onMoveDown: () => _moveExercise(index, 1),
                            onDelete:
                                () => setState(() {
                                  day.exercises.removeAt(index);
                                  _commit();
                                }),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExercise() async {
    final picked = await showExercisePickerSheet(
      context,
      library: widget.library,
      selected: _plan[_selectedDay].exercises.lastOrNull,
    );
    if (picked == null) return;
    setState(() {
      _plan[_selectedDay].exercises.add(picked);
      _commit();
    });
  }

  void _moveExercise(int index, int direction) {
    final day = _plan[_selectedDay];
    final target = index + direction;
    if (target < 0 || target >= day.exercises.length) return;
    setState(() {
      final exercise = day.exercises.removeAt(index);
      day.exercises.insert(target, exercise);
      _commit();
    });
  }

  void _addDay() {
    if (_plan.length >= 14) return;
    setState(() {
      final nextNumber = _plan.length + 1;
      final fallback =
          fallbackCycle[(nextNumber - 1).clamp(0, fallbackCycle.length - 1)];
      _plan.add(
        _CustomWorkoutPlanDay(
          dayNumber: nextNumber,
          name:
              nextNumber <= fallbackCycle.length
                  ? fallback.name
                  : 'Workout Day $nextNumber',
          isRestDay: false,
          exercises: [],
        ),
      );
      _selectedDay = _plan.length - 1;
      _commit();
    });
  }

  void _deleteSelectedDay() {
    if (_plan.length <= 1) return;
    setState(() {
      _plan.removeAt(_selectedDay);
      if (_selectedDay >= _plan.length) _selectedDay = _plan.length - 1;
      _commit();
    });
  }

  void _commit() {
    widget.onChanged([
      for (var index = 0; index < _plan.length; index++)
        _plan[index].copyWith(dayNumber: index + 1),
    ]);
  }
}

class _SessionWorkoutOption extends StatelessWidget {
  const _SessionWorkoutOption({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final _CustomWorkoutPlanDay day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AtlasPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color:
              selected
                  ? AtlasColors.accent.withValues(alpha: isDark ? 0.18 : 0.1)
                  : isDark
                  ? Colors.white.withValues(alpha: 0.055)
                  : AtlasColors.surfaceWarm,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                selected
                    ? AtlasColors.accent.withValues(alpha: 0.28)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : AtlasColors.hairline,
          ),
        ),
        child: Row(
          children: [
            _WorkoutDayGlyph(workout: _workoutFromPlanDay(day), size: 42),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Day ${day.dayNumber}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    day.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color:
                  selected
                      ? AtlasColors.accent
                      : isDark
                      ? Colors.white.withValues(alpha: 0.42)
                      : AtlasColors.inkSoft,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanExerciseTile extends StatelessWidget {
  const _PlanExerciseTile({
    required this.exercise,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
  });

  final AtlasExercise exercise;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AtlasColors.hairline,
        ),
      ),
      child: Row(
        children: [
          _ExerciseMediaPreview(
            exercise: exercise,
            visual: exerciseVisual(exercise),
            size: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  '${exercise.primaryMuscle} / ${exercise.equipment}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canMoveUp ? onMoveUp : null,
            icon: const Icon(Icons.keyboard_arrow_up_rounded),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: canMoveDown ? onMoveDown : null,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
    );
  }
}

class _PlanEmptyState extends StatelessWidget {
  const _PlanEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.event_available_rounded, color: AtlasColors.inkSoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _CompletedWorkoutExerciseList extends StatelessWidget {
  const _CompletedWorkoutExerciseList({required this.report});

  final AtlasWorkoutReport report;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        for (final exercise in report.exercises) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.055)
                      : Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.09)
                        : AtlasColors.hairline,
              ),
            ),
            child: Row(
              children: [
                _ReportExerciseMedia(exercise: exercise, size: 56),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _exerciseSummaryLabel(exercise),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.lock_outline_rounded,
                  color:
                      isDark
                          ? Colors.white.withValues(alpha: 0.42)
                          : AtlasColors.inkSoft,
                  size: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showWorkoutReportSheet(context, report),
            icon: const Icon(Icons.receipt_long_rounded),
            label: const Text('Review Workout Report'),
          ),
        ),
      ],
    );
  }
}

Future<void> _showWorkoutReportSheet(
  BuildContext context,
  AtlasWorkoutReport report,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _WorkoutReportSheet(report: report),
  );
}

class _WorkoutReportSheet extends StatelessWidget {
  const _WorkoutReportSheet({required this.report});

  final AtlasWorkoutReport report;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.paddingOf(context).bottom + 22,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                _HeroChip(label: '${report.totalExercises} exercises'),
                _HeroChip(label: _reportLoadChip(report)),
                if (_strengthVolume(report) > 0)
                  _HeroChip(
                    label:
                        '${_strengthVolume(report).toStringAsFixed(0)} kg volume',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: report.exercises.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder:
                    (context, index) =>
                        _WorkoutReportExerciseTile(report.exercises[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutReportExerciseTile extends StatelessWidget {
  const _WorkoutReportExerciseTile(this.exercise);

  final AtlasWorkoutExerciseLog exercise;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.055)
                : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AtlasColors.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ReportExerciseMedia(exercise: exercise, size: 58),
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
                      .map((set) => _reportSetLabel(exercise, set))
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

class _ReportExerciseMedia extends StatelessWidget {
  const _ReportExerciseMedia({required this.exercise, required this.size});

  final AtlasWorkoutExerciseLog exercise;
  final double size;

  @override
  Widget build(BuildContext context) {
    final atlasExercise = exercise.exercise;
    final mediaUrl =
        atlasExercise == null ? null : _exerciseMediaUrl(atlasExercise);
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child:
          mediaUrl == null
              ? Container(
                width: size,
                height: size,
                color: AtlasColors.accentSoft,
                child: const Icon(Icons.fitness_center_rounded),
              )
              : CachedNetworkImage(
                imageUrl: mediaUrl,
                width: size,
                height: size,
                fit: BoxFit.cover,
              ),
    );
  }
}

String _weightLabel(AtlasWorkoutSetLog set) {
  if (set.weight == 0) return 'bodyweight';
  final value =
      set.weight == set.weight.roundToDouble()
          ? set.weight.round().toString()
          : set.weight.toStringAsFixed(1);
  return '$value ${set.weightUnit}';
}

String _reportSetLabel(
  AtlasWorkoutExerciseLog exercise,
  AtlasWorkoutSetLog set,
) {
  final atlasExercise = exercise.exercise;
  final isCardio =
      atlasExercise != null && _isCardioStyleExercise(atlasExercise);
  if (isCardio) {
    final distance =
        set.weight == 0
            ? ''
            : ' / ${set.weight == set.weight.roundToDouble() ? set.weight.round() : set.weight.toStringAsFixed(1)} km';
    return '${set.reps} min$distance';
  }
  return 'Set ${set.setNumber}: ${set.reps} reps x ${_weightLabel(set)}';
}

String _exerciseSummaryLabel(AtlasWorkoutExerciseLog exercise) {
  final atlasExercise = exercise.exercise;
  final isCardio =
      atlasExercise != null && _isCardioStyleExercise(atlasExercise);
  if (isCardio) {
    final minutes = exercise.sets.fold(0, (sum, set) => sum + set.reps);
    final distance = exercise.sets.fold<double>(
      0,
      (sum, set) => sum + set.weight,
    );
    return '$minutes min${distance == 0 ? '' : ' / ${_compactDouble(distance)} km'}';
  }
  return '${exercise.totalSets} sets / ${exercise.totalReps} reps / ${exercise.totalVolume.toStringAsFixed(0)} kg';
}

String _reportLoadChip(AtlasWorkoutReport? report) {
  if (report == null) return 'Saved session';
  final cardioMinutes = report.exercises
      .where(
        (exercise) =>
            exercise.exercise != null &&
            _isCardioStyleExercise(exercise.exercise!),
      )
      .fold<int>(
        0,
        (sum, exercise) =>
            sum + exercise.sets.fold(0, (setSum, set) => setSum + set.reps),
      );
  final strengthSets = report.exercises
      .where(
        (exercise) =>
            exercise.exercise == null ||
            !_isCardioStyleExercise(exercise.exercise!),
      )
      .fold<int>(0, (sum, exercise) => sum + exercise.totalSets);
  if (strengthSets > 0 && cardioMinutes > 0) {
    return '$strengthSets sets / $cardioMinutes min';
  }
  if (cardioMinutes > 0) return '$cardioMinutes cardio min';
  return '$strengthSets sets';
}

double _strengthVolume(AtlasWorkoutReport report) {
  return report.exercises
      .where(
        (exercise) =>
            exercise.exercise == null ||
            !_isCardioStyleExercise(exercise.exercise!),
      )
      .fold<double>(0, (sum, exercise) => sum + exercise.totalVolume);
}

String _compactDouble(double value) {
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
}

class _ExerciseEditor extends StatelessWidget {
  const _ExerciseEditor({
    required this.index,
    required this.entry,
    required this.library,
    required this.onChanged,
    required this.onDelete,
  });

  final int index;
  final _EditableWorkoutEntry entry;
  final List<AtlasExercise> library;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final visual = exerciseVisual(entry.exercise);
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ExerciseMediaPreview(
                exercise: entry.exercise,
                visual: visual,
                index: index,
                size: 54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AtlasPressable(
                  onTap: () => _pickExercise(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.exercise.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${entry.exercise.primaryMuscle} / ${entry.exercise.equipment} / ${entry.exercise.difficulty}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: () => _pickExercise(context),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Choose exercise',
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AtlasColors.inkSoft,
                tooltip: 'Remove exercise',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _SetInputPanel(entry: entry, onChanged: onChanged),
        ],
      ),
    );
  }

  Future<void> _pickExercise(BuildContext context) async {
    final picked = await showExercisePickerSheet(
      context,
      library: library,
      selected: entry.exercise,
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    entry.exercise = picked;
    entry.sets = _defaultSetsFor(picked);
    entry.reps = _defaultRepsFor(picked);
    if (_isCardioStyleExercise(picked)) {
      entry.weight = 0;
    }
    entry._syncSetRows();
    onChanged();
  }
}

Future<AtlasExercise?> showExercisePickerSheet(
  BuildContext context, {
  required List<AtlasExercise> library,
  AtlasExercise? selected,
}) {
  return showModalBottomSheet<AtlasExercise>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => _ExercisePickerSheet(library: library, selected: selected),
  );
}

class _ExercisePickerSheet extends StatefulWidget {
  const _ExercisePickerSheet({required this.library, required this.selected});

  final List<AtlasExercise> library;
  final AtlasExercise? selected;

  @override
  State<_ExercisePickerSheet> createState() => _ExercisePickerSheetState();
}

class _ExercisePickerSheetState extends State<_ExercisePickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _muscleFilter;
  bool _includeExercisesWithoutImages = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered =
        widget.library.where((exercise) {
            final query = _query.toLowerCase();
            if (!_includeExercisesWithoutImages &&
                !_exerciseHasMedia(exercise)) {
              return false;
            }
            final matchesSearch =
                query.isEmpty || _exerciseSearchText(exercise).contains(query);
            final matchesMuscle =
                _muscleFilter == null ||
                _exerciseMatchesSimpleMuscle(exercise, _muscleFilter!);
            return matchesSearch && matchesMuscle;
          }).toList()
          ..sort(
            (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
          );

    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        bottomInset + MediaQuery.paddingOf(context).bottom + 18,
      ),
      child: SizedBox(
        height:
            MediaQuery.sizeOf(context).height * (bottomInset > 0 ? 0.56 : 0.76),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Choose Exercise'),
            const SizedBox(height: 6),
            Text(
              'Choose movement, then log sets, reps, and weight.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search exercises',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
            ),
            const SizedBox(height: 14),
            _SimpleMuscleFilterChips(
              selected: _muscleFilter,
              onSelected: (value) => setState(() => _muscleFilter = value),
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _includeExercisesWithoutImages,
              onChanged:
                  (value) =>
                      setState(() => _includeExercisesWithoutImages = value),
              title: Text(
                'Include exercises without images',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              subtitle: Text(
                'Advanced library view',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child:
                  filtered.isEmpty
                      ? _ExerciseSearchEmptyState(
                        hasQueryOrFilter:
                            _query.trim().isNotEmpty || _muscleFilter != null,
                      )
                      : Scrollbar(
                        child: ListView.separated(
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemBuilder: (context, index) {
                            final exercise = filtered[index];
                            final selectedRow = exercise == widget.selected;
                            final hasMedia = _exerciseHasMedia(exercise);
                            return AtlasPressable(
                              onTap: () => Navigator.pop(context, exercise),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color:
                                      selectedRow
                                          ? AtlasColors.accent.withValues(
                                            alpha: isDark ? 0.18 : 0.08,
                                          )
                                          : isDark
                                          ? Colors.white.withValues(
                                            alpha: 0.055,
                                          )
                                          : Colors.white.withValues(
                                            alpha: 0.68,
                                          ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        selectedRow
                                            ? AtlasColors.accent.withValues(
                                              alpha: isDark ? 0.3 : 0.2,
                                            )
                                            : isDark
                                            ? Colors.white.withValues(
                                              alpha: 0.09,
                                            )
                                            : AtlasColors.hairline,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    _ExerciseMediaPreview(
                                      exercise: exercise,
                                      visual: exerciseVisual(exercise),
                                      size: 70,
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            exercise.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 6,
                                            children: [
                                              _ExerciseMetaChip(
                                                label: exercise.primaryMuscle,
                                              ),
                                              _ExerciseMetaChip(
                                                label: exercise.equipment,
                                              ),
                                              _ExerciseMetaChip(
                                                label: exercise.difficulty,
                                              ),
                                              if (!hasMedia)
                                                const _ExerciseMetaChip(
                                                  label: 'No image',
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(
                                      selectedRow
                                          ? Icons.radio_button_checked_rounded
                                          : Icons.radio_button_off_rounded,
                                      color:
                                          selectedRow
                                              ? AtlasColors.accent
                                              : isDark
                                              ? Colors.white.withValues(
                                                alpha: 0.42,
                                              )
                                              : AtlasColors.inkSoft,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 10),
                          itemCount: filtered.length,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseSearchEmptyState extends StatelessWidget {
  const _ExerciseSearchEmptyState({required this.hasQueryOrFilter});

  final bool hasQueryOrFilter;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.055)
                  : Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.09)
                    : AtlasColors.hairline,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AtlasColors.accentSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AtlasColors.accent,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'No exercises found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              hasQueryOrFilter
                  ? 'Try another name or clear your filters.'
                  : 'Turn on advanced library view to include exercises without images.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleMuscleFilterChips extends StatelessWidget {
  const _SimpleMuscleFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final value = _simpleMuscleFilters[index];
          final isAll = value == _allExerciseFilter;
          final isSelected = isAll ? selected == null : selected == value;
          return ChoiceChip(
            label: Text(value),
            selected: isSelected,
            onSelected: (_) => onSelected(isAll ? null : value),
            avatar:
                isSelected ? const Icon(Icons.check_rounded, size: 18) : null,
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: _simpleMuscleFilters.length,
      ),
    );
  }
}

class _ExerciseMetaChip extends StatelessWidget {
  const _ExerciseMetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.07)
                : AtlasColors.surfaceWarm,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.09)
                  : AtlasColors.hairline,
        ),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.78)
                  : AtlasColors.inkMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

const _allExerciseFilter = 'All';
const _simpleMuscleFilters = [
  _allExerciseFilter,
  'Chest',
  'Triceps',
  'Back',
  'Biceps',
  'Legs',
  'Shoulders',
  'Arms',
  'Abs',
  'Glutes',
  'Cardio',
];

bool _exerciseMatchesSimpleMuscle(AtlasExercise exercise, String filter) {
  final primaryGroup = _simpleMuscleGroup(exercise.primaryMuscle);
  if (filter == 'Arms') {
    return primaryGroup == 'Biceps' ||
        primaryGroup == 'Triceps' ||
        primaryGroup == 'Forearms';
  }
  return primaryGroup == filter;
}

String _exerciseSearchText(AtlasExercise exercise) {
  return [
    exercise.name,
    exercise.primaryMuscle,
    ...exercise.secondaryMuscles,
    exercise.equipment,
    exercise.difficulty,
    exercise.pattern,
    exercise.movementType,
    ..._exerciseAliases(exercise),
    ...exercise.instructions,
  ].join(' ').toLowerCase();
}

List<String> _exerciseAliases(AtlasExercise exercise) {
  final name = exercise.name.toLowerCase();
  return [
    if (name.contains('dumbbell')) 'db',
    if (name.contains('barbell')) 'bb',
    if (name.contains('pulldown')) 'pull down cable pulldown lat pulldown',
    if (name.contains('bench')) 'flat bench press',
    if (name.contains('pushdown')) 'triceps pressdown cable pushdown',
    if (name.contains('row')) 'pull back rowing',
  ];
}

String _simpleMuscleGroup(String value) {
  final normalized = value.toLowerCase().replaceAll(RegExp(r'[^a-z]+'), ' ');
  if (normalized.contains('chest') || normalized.contains('pectoral')) {
    return 'Chest';
  }
  if (normalized.contains('tricep')) return 'Triceps';
  if (normalized.contains('bicep')) return 'Biceps';
  if (normalized.contains('forearm')) return 'Forearms';
  if (normalized.contains('lat') ||
      normalized.contains('back') ||
      normalized.contains('trap') ||
      normalized.contains('rhomboid')) {
    return 'Back';
  }
  if (normalized.contains('shoulder') || normalized.contains('deltoid')) {
    return 'Shoulders';
  }
  if (normalized.contains('ab') ||
      normalized.contains('core') ||
      normalized.contains('oblique') ||
      normalized.contains('waist')) {
    return 'Abs';
  }
  if (normalized.contains('glute')) return 'Glutes';
  if (normalized.contains('quad') ||
      normalized.contains('hamstring') ||
      normalized.contains('calf') ||
      normalized.contains('calve') ||
      normalized.contains('leg') ||
      normalized.contains('adductor') ||
      normalized.contains('abductor')) {
    return 'Legs';
  }
  if (normalized.contains('cardio') || normalized.contains('aerobic')) {
    return 'Cardio';
  }
  return '';
}

bool _exerciseHasMedia(AtlasExercise exercise) =>
    _exerciseMediaUrl(exercise) != null;

String? _exerciseMediaUrl(AtlasExercise exercise) {
  final mediaUrl =
      exercise.previewGif ??
      exercise.gifUrl ??
      exercise.thumbnail ??
      exercise.previewImage ??
      exercise.imageUrl;
  if (mediaUrl == null || mediaUrl.trim().isEmpty) {
    return null;
  }
  return mediaUrl;
}

class _AnimatedExerciseGlyph extends StatelessWidget {
  const _AnimatedExerciseGlyph({this.visual, this.index, this.size = 70});

  final ExerciseVisual? visual;
  final int? index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final resolved = visual ?? exerciseVisual(fallbackExercises.first);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1100),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.96 + value * 0.04,
          child: Transform.translate(
            offset: Offset(0, -3 * (1 - (value - 0.5).abs() * 2)),
            child: child,
          ),
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: resolved.gradient),
          borderRadius: BorderRadius.circular(size * 0.34),
          boxShadow: [
            BoxShadow(
              color: resolved.gradient.first.withValues(alpha: 0.24),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (index != null)
              Positioned(
                right: 9,
                top: 8,
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ),
            Center(
              child: Icon(
                resolved.icon,
                color: Colors.white,
                size: size * 0.42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExerciseMediaPreview extends StatelessWidget {
  const _ExerciseMediaPreview({
    required this.exercise,
    required this.visual,
    this.index,
    this.size = 64,
  });

  final AtlasExercise exercise;
  final ExerciseVisual visual;
  final int? index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final mediaUrl = _exerciseMediaUrl(exercise);
    if (mediaUrl == null || mediaUrl.isEmpty) {
      return _AnimatedExerciseGlyph(visual: visual, index: index, size: size);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Stack(
        children: [
          CachedNetworkImage(
            imageUrl: mediaUrl,
            width: size,
            height: size,
            fit: BoxFit.cover,
            fadeInDuration: const Duration(milliseconds: 180),
            placeholder:
                (_, __) => _AnimatedExerciseGlyph(
                  visual: visual,
                  index: index,
                  size: size,
                ),
            errorWidget:
                (_, __, ___) => _AnimatedExerciseGlyph(
                  visual: visual,
                  index: index,
                  size: size,
                ),
          ),
          if (index != null)
            Positioned(
              right: 6,
              top: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$index',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SetInputPanel extends StatelessWidget {
  const _SetInputPanel({required this.entry, required this.onChanged});

  final _EditableWorkoutEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isCardio = _isCardioStyleExercise(entry.exercise);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.045)
                : AtlasColors.surfaceWarm.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : AtlasColors.hairline,
        ),
      ),
      child:
          isCardio
              ? _CardioInputRows(entry: entry, onChanged: onChanged)
              : _StrengthSetRows(entry: entry, onChanged: onChanged),
    );
  }
}

class _StrengthSetRows extends StatelessWidget {
  const _StrengthSetRows({required this.entry, required this.onChanged});

  final _EditableWorkoutEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Text('Set', style: Theme.of(context).textTheme.labelLarge),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Text(
                'Reps',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 3,
              child: Text('Kg', style: Theme.of(context).textTheme.labelLarge),
            ),
          ],
        ),
        const SizedBox(height: 8),
        for (final set in entry.setRows) ...[
          _StrengthSetRow(
            set: set,
            onChanged: () {
              entry.reps =
                  entry.setRows.isEmpty ? entry.reps : entry.setRows.first.reps;
              entry.weight =
                  entry.setRows.isEmpty
                      ? entry.weight
                      : entry.setRows.first.weight;
              onChanged();
            },
          ),
          if (set != entry.setRows.last) const SizedBox(height: 8),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  entry.setSetCount(entry.sets + 1);
                  onChanged();
                },
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add Set'),
              ),
            ),
            if (entry.sets > 1) ...[
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: () {
                  entry.setSetCount(entry.sets - 1);
                  onChanged();
                },
                icon: const Icon(Icons.remove_rounded),
                tooltip: 'Remove last set',
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _StrengthSetRow extends StatelessWidget {
  const _StrengthSetRow({required this.set, required this.onChanged});

  final _EditableSetRow set;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Container(
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AtlasColors.accentSoft.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : AtlasColors.hairline,
              ),
            ),
            child: Text(
              '${set.setNumber}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color:
                    isDark
                        ? Theme.of(context).colorScheme.primary
                        : AtlasColors.accent,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _InlineIntField(
            value: set.reps,
            onChanged: (value) {
              set.reps = value;
              onChanged();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 3,
          child: _InlineNumberField(
            label: '',
            value: set.weight,
            onChanged: (value) {
              set.weight = value;
              onChanged();
            },
          ),
        ),
      ],
    );
  }
}

class _CardioInputRows extends StatelessWidget {
  const _CardioInputRows({required this.entry, required this.onChanged});

  final _EditableWorkoutEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _LabeledInput(
            label: 'Minutes',
            child: _InlineIntField(
              value: entry.reps,
              onChanged: (value) {
                entry.reps = value;
                onChanged();
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _LabeledInput(
            label: 'Distance km',
            child: _InlineNumberField(
              label: '',
              value: entry.weight,
              onChanged: (value) {
                entry.weight = value;
                onChanged();
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _InlineIntField extends StatefulWidget {
  const _InlineIntField({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_InlineIntField> createState() => _InlineIntFieldState();
}

class _InlineIntFieldState extends State<_InlineIntField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(covariant _InlineIntField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_controller.selection.isValid) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '0',
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      ),
      onTap: () {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
      onChanged:
          (value) => widget.onChanged(
            (int.tryParse(value.trim()) ?? 0).clamp(0, 999).toInt(),
          ),
    );
  }
}

class _InlineNumberField extends StatefulWidget {
  const _InlineNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_InlineNumberField> createState() => _InlineNumberFieldState();
}

class _InlineNumberFieldState extends State<_InlineNumberField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _formatWeight(widget.value));
  }

  @override
  void didUpdateWidget(covariant _InlineNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_controller.selection.isValid) {
      _controller.text = _formatWeight(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.titleMedium,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: widget.label.isEmpty ? '0' : null,
        labelText: widget.label.isEmpty ? null : widget.label,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 13),
      ),
      onTap: () {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
      onChanged:
          (value) => widget.onChanged(double.tryParse(value.trim()) ?? 0),
    );
  }
}

String _formatWeight(double value) {
  if (value == 0) {
    return '';
  }
  return value == value.roundToDouble()
      ? value.round().toString()
      : value.toStringAsFixed(1);
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

class _EditableWorkoutEntry {
  _EditableWorkoutEntry(this.exercise)
    : sets = _defaultSetsFor(exercise),
      reps = _defaultRepsFor(exercise),
      weight = 0 {
    _syncSetRows();
  }

  _EditableWorkoutEntry.fromDraft(
    this.exercise, {
    required Object? sets,
    required Object? reps,
    required Object? weight,
    required Object? setRows,
  }) : sets =
           sets is num
               ? sets.round().clamp(1, 99).toInt()
               : _defaultSetsFor(exercise),
       reps =
           reps is num
               ? reps.round().clamp(1, 999).toInt()
               : _defaultRepsFor(exercise),
       weight =
           weight is num ? weight.toDouble().clamp(0, 9999).toDouble() : 0 {
    if (setRows is List && setRows.isNotEmpty) {
      this.setRows.addAll([
        for (final row in setRows)
          if (row is Map)
            _EditableSetRow(
              setNumber:
                  row['setNumber'] is num
                      ? (row['setNumber'] as num).round().clamp(1, 99).toInt()
                      : this.setRows.length + 1,
              reps:
                  row['reps'] is num
                      ? (row['reps'] as num).round().clamp(1, 999).toInt()
                      : this.reps,
              weight:
                  row['weight'] is num
                      ? (row['weight'] as num)
                          .toDouble()
                          .clamp(0, 9999)
                          .toDouble()
                      : this.weight,
            ),
      ]);
    }
    _syncSetRows();
  }

  AtlasExercise exercise;
  int sets;
  int reps;
  double weight;
  final List<_EditableSetRow> setRows = [];

  void setSetCount(int value) {
    sets = value.clamp(1, 99);
    _syncSetRows();
  }

  void _syncSetRows() {
    if (_isCardioStyleExercise(exercise)) {
      setRows.clear();
      return;
    }
    while (setRows.length < sets) {
      setRows.add(
        _EditableSetRow(
          setNumber: setRows.length + 1,
          reps: reps,
          weight: weight,
        ),
      );
    }
    if (setRows.length > sets) {
      setRows.removeRange(sets, setRows.length);
    }
    for (var index = 0; index < setRows.length; index++) {
      setRows[index].setNumber = index + 1;
    }
  }
}

class _EditableSetRow {
  _EditableSetRow({
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  int setNumber;
  int reps;
  double weight;
}

class _CustomWorkoutPlanDay {
  _CustomWorkoutPlanDay({
    required this.dayNumber,
    required this.name,
    required this.isRestDay,
    required this.exercises,
  });

  final int dayNumber;
  String name;
  bool isRestDay;
  final List<AtlasExercise> exercises;

  _CustomWorkoutPlanDay copy() {
    return _CustomWorkoutPlanDay(
      dayNumber: dayNumber,
      name: name,
      isRestDay: isRestDay,
      exercises: [...exercises],
    );
  }

  _CustomWorkoutPlanDay copyWith({
    int? dayNumber,
    String? name,
    bool? isRestDay,
    List<AtlasExercise>? exercises,
  }) {
    return _CustomWorkoutPlanDay(
      dayNumber: dayNumber ?? this.dayNumber,
      name: name ?? this.name,
      isRestDay: isRestDay ?? this.isRestDay,
      exercises: exercises ?? [...this.exercises],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'name': name,
      'isRestDay': isRestDay,
      'exerciseIds': [for (final exercise in exercises) exercise.id],
    };
  }
}

List<_CustomWorkoutPlanDay> _defaultCustomPlan() {
  return [
    for (final day in fallbackCycle)
      _CustomWorkoutPlanDay(
        dayNumber: day.dayNumber,
        name: day.name,
        isRestDay: day.isRestDay,
        exercises: [],
      ),
  ];
}

List<_CustomWorkoutPlanDay> _loadCustomWorkoutPlan(
  List<Map<String, dynamic>> rawPlan,
  List<AtlasExercise> library,
) {
  if (rawPlan.isEmpty) {
    return _defaultCustomPlan();
  }
  final byId = {for (final exercise in library) exercise.id: exercise};
  final defaults = _defaultCustomPlan();
  final loaded = <_CustomWorkoutPlanDay>[];
  final length = rawPlan.length.clamp(1, 14).toInt();
  for (var index = 0; index < length; index++) {
    final raw = rawPlan.firstWhere(
      (item) => item['dayNumber'] == index + 1,
      orElse: () => const {},
    );
    final exerciseIds = raw['exerciseIds'];
    final fallback = defaults[index.clamp(0, defaults.length - 1)];
    loaded.add(
      _CustomWorkoutPlanDay(
        dayNumber: index + 1,
        name: raw['name'] as String? ?? fallback.name,
        isRestDay: raw['isRestDay'] as bool? ?? fallback.isRestDay,
        exercises: [
          if (exerciseIds is List)
            for (final id in exerciseIds)
              if (id is String && byId[id] != null) byId[id]!,
        ],
      ),
    );
  }
  return loaded;
}

AtlasDashboardSnapshot _applyCustomWorkoutPlan(
  AtlasDashboardSnapshot snapshot,
  List<_CustomWorkoutPlanDay> plan,
) {
  AtlasWorkoutDay? mapDay(AtlasWorkoutDay? source) {
    if (source == null) return null;
    final index = source.dayNumber.clamp(1, plan.length) - 1;
    final custom = plan[index];
    return AtlasWorkoutDay(
      dayNumber: source.dayNumber,
      name: custom.name.isEmpty ? source.name : custom.name,
      focus:
          custom.isRestDay
              ? 'Recovery, mobility, hydration, and readiness'
              : 'Custom workout plan',
      isRestDay: custom.isRestDay,
      workoutDayId: source.workoutDayId,
      templateId: source.templateId,
    );
  }

  final workout = mapDay(snapshot.todayWorkout ?? snapshot.starterWorkout);
  final plannedExercises =
      workout == null
          ? const <AtlasWorkoutExercise>[]
          : [
            for (final exercise
                in plan[workout.dayNumber.clamp(1, plan.length) - 1].exercises)
              AtlasWorkoutExercise(
                exercise: exercise,
                targetSets: exercise.defaultSets,
                targetReps: exercise.defaultReps,
                notes: '',
              ),
          ];

  return AtlasDashboardSnapshot(
    todayWorkout: snapshot.todayWorkout == null ? null : workout,
    starterWorkout: snapshot.starterWorkout == null ? null : workout,
    templateExercises: plannedExercises,
    exerciseLibrary: snapshot.exerciseLibrary,
    completedThisWeek: snapshot.completedThisWeek,
    weeklyTarget: snapshot.weeklyTarget,
    totalWorkouts: snapshot.totalWorkouts,
    monthWorkouts: snapshot.monthWorkouts,
    completedToday: snapshot.completedToday,
    cycleStarted: snapshot.cycleStarted,
    currentStreak: snapshot.currentStreak,
    hydrationToday: snapshot.hydrationToday,
    activeGoals: snapshot.activeGoals,
    latestWeight: snapshot.latestWeight,
    latestWeightUnit: snapshot.latestWeightUnit,
    latestWeightDate: snapshot.latestWeightDate,
    lastWorkoutTitle: snapshot.lastWorkoutTitle,
    todayReport: snapshot.todayReport,
  );
}

AtlasWorkoutDay _workoutFromPlanDay(
  _CustomWorkoutPlanDay day, {
  AtlasWorkoutDay? base,
}) {
  final canReuseBaseIds = base?.dayNumber == day.dayNumber;
  return AtlasWorkoutDay(
    dayNumber: day.dayNumber,
    name: day.name.isEmpty ? 'Workout' : day.name,
    focus:
        day.isRestDay
            ? 'Recovery, mobility, hydration, and readiness'
            : 'Selected for this workout log',
    isRestDay: day.isRestDay,
    workoutDayId: canReuseBaseIds ? base?.workoutDayId : null,
    templateId: canReuseBaseIds ? base?.templateId : null,
  );
}

int _firstNumber(String value) {
  final match = RegExp(r'\d+').firstMatch(value);
  return int.tryParse(match?.group(0) ?? '') ?? 15;
}

int _defaultSetsFor(AtlasExercise exercise) {
  return _isCardioStyleExercise(exercise) ? 1 : exercise.defaultSets;
}

int _defaultRepsFor(AtlasExercise exercise) {
  return _isCardioStyleExercise(exercise)
      ? 20
      : _firstNumber(exercise.defaultReps);
}

bool _isCardioStyleExercise(AtlasExercise exercise) {
  final text =
      '${exercise.name} ${exercise.primaryMuscle} ${exercise.movementType} ${exercise.pattern}'
          .toLowerCase();
  return text.contains('cardio') ||
      text.contains('treadmill') ||
      text.contains('running') ||
      text.contains('cycling') ||
      text.contains('bike') ||
      text.contains('elliptical') ||
      text.contains('rowing') ||
      text.contains('stair') ||
      text.contains('jump rope') ||
      text.contains('walking');
}

String _dateKey(DateTime value) {
  final local = value.toLocal();
  return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
}
