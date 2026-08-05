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
  const TrainScreen({super.key});

  @override
  State<TrainScreen> createState() => _TrainScreenState();
}

class _TrainScreenState extends State<TrainScreen> {
  Future<AtlasDashboardSnapshot>? _future;
  AtlasDataRepository? _repository;
  AppDependencies? _dependencies;
  List<_CustomWorkoutPlanDay> _customPlan = _defaultCustomPlan();
  final List<_EditableWorkoutEntry> _entries = [];
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dependencies = AppScope.maybeRead(context);
    _repository = _dependencies?.atlasDataRepository;
    _future ??= _load();
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
    final workout =
        effectiveSnapshot.todayWorkout ?? effectiveSnapshot.starterWorkout;
    if (effectiveSnapshot.completedToday) {
      await _clearDraft();
      return effectiveSnapshot;
    }
    final restored = _restoreDraft(workout, effectiveSnapshot.exerciseLibrary);
    if (restored) {
      return effectiveSnapshot;
    }
    final plannedDay =
        workout == null ? null : _customPlan[workout.dayNumber.clamp(1, 5) - 1];
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
    final workout = snapshot.todayWorkout ?? snapshot.starterWorkout;
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
            ),
        ],
      );
      if (!mounted) return;
      unawaited(_clearDraft());
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
          barrierColor: Colors.black.withValues(alpha: 0.28),
          transitionDuration: const Duration(milliseconds: 240),
          pageBuilder:
              (context, animation, secondaryAnimation) => Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: MediaQuery.sizeOf(context).width - 42,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.52),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AtlasColors.ink.withValues(alpha: 0.14),
                          blurRadius: 34,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AtlasColors.successSoft,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: AtlasColors.success,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Save today\'s workout?',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Atlas will lock $workoutName with $exerciseCount exercises for today and add it to Workout History.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => Navigator.pop(context, true),
                                icon: const Icon(Icons.check_rounded),
                                label: const Text('Save Workout'),
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
                      curve: Curves.easeOutBack,
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
        final workout = data.todayWorkout ?? data.starterWorkout;
        return AtlasAppFrame(
          subtitle:
              data.hasWorkoutCycleStarted
                  ? workout?.name ?? 'Today\'s workout'
                  : 'Start with Day 1 when you are ready',
          title: 'Train',
          children: [
            _WorkoutHero(
              snapshot: data,
              saving: _saving,
              onSave: () => _saveWorkout(data),
              onEditPlan: () => _showPlanEditor(data.exerciseLibrary),
            ),
            _ExerciseLogger(
              library: data.exerciseLibrary,
              entries: _entries,
              completedReport: data.todayReport,
              onChanged: () => _handleEntriesChanged(data),
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
    final saved = await _showWorkoutPlanEditorSheet(
      context,
      library: library,
      initialPlan: _customPlan,
    );
    if (saved == null) return;
    await _dependencies?.preferences.setCustomWorkoutPlan([
      for (final day in saved) day.toJson(),
    ]);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _customPlan = saved;
      _future = _load();
    });
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
        ),
      );
    }
    if (restored.isEmpty) return false;
    _entries.addAll(restored);
    return true;
  }

  Future<void> _saveDraft(AtlasDashboardSnapshot snapshot) async {
    final userId = _repository?.currentUserId;
    final workout = snapshot.todayWorkout ?? snapshot.starterWorkout;
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
          },
      ],
    });
  }

  Future<void> _clearDraft() async {
    final userId = _repository?.currentUserId;
    if (userId == null) return;
    await _dependencies?.preferences.clearWorkoutDraft(userId);
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({
    required this.snapshot,
    required this.saving,
    required this.onSave,
    required this.onEditPlan,
  });

  final AtlasDashboardSnapshot snapshot;
  final bool saving;
  final VoidCallback onSave;
  final VoidCallback onEditPlan;

  @override
  Widget build(BuildContext context) {
    final workout = snapshot.todayWorkout ?? snapshot.starterWorkout;
    final isFirst = !snapshot.hasWorkoutCycleStarted;
    final savedToday = snapshot.completedToday;
    final report = snapshot.todayReport;
    final totalSets = snapshot.templateExercises.fold<int>(
      0,
      (sum, item) => sum + item.targetSets,
    );

    return AtlasCard(
      isGlass: true,
      radius: 30,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _AnimatedExerciseGlyph(size: 58),
              const SizedBox(width: 14),
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
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      report?.title ?? workout?.name ?? 'Choose your workout',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            savedToday
                ? 'Saved, locked, and available in Workout History.'
                : isFirst
                ? 'Save this session to start Atlas. The next planned day unlocks only after you complete this workout.'
                : workout?.focus ?? 'Log clean sets, reps, weight, and rest.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(
                label:
                    savedToday
                        ? '${report?.totalExercises ?? 0} exercises'
                        : '${snapshot.templateExercises.length} moves',
              ),
              _HeroChip(
                label:
                    savedToday
                        ? '${report?.totalSets ?? 0} sets'
                        : totalSets == 0
                        ? 'Manual build'
                        : '$totalSets target sets',
              ),
              _HeroChip(
                label:
                    savedToday
                        ? _durationLabel(report?.duration)
                        : isFirst
                        ? 'Cycle not started'
                        : 'Day ${workout?.dayNumber ?? 1}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AtlasGradientButton(
                  label:
                      savedToday
                          ? 'Workout Saved Today'
                          : saving
                          ? 'Saving'
                          : isFirst
                          ? 'Save First Workout'
                          : 'Complete Workout',
                  icon:
                      savedToday
                          ? Icons.verified_rounded
                          : saving
                          ? Icons.sync_rounded
                          : Icons.check_rounded,
                  colors: const [AtlasColors.success, AtlasColors.accent],
                  onPressed:
                      savedToday && report != null
                          ? () => _showWorkoutReportSheet(context, report)
                          : saving
                          ? null
                          : onSave,
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                onPressed: onEditPlan,
                icon: const Icon(Icons.edit_calendar_rounded),
                tooltip: 'Edit workout plan',
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _ExerciseLogger extends StatelessWidget {
  const _ExerciseLogger({
    required this.library,
    required this.entries,
    required this.completedReport,
    required this.onChanged,
    required this.onAdd,
  });

  final List<AtlasExercise> library;
  final List<_EditableWorkoutEntry> entries;
  final AtlasWorkoutReport? completedReport;
  final VoidCallback onChanged;
  final VoidCallback? onAdd;

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
              _BottomAddExerciseButton(onPressed: onAdd),
            ],
          ],
      ],
    );
  }
}

class _BottomAddExerciseButton extends StatelessWidget {
  const _BottomAddExerciseButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Exercise'),
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

Future<List<_CustomWorkoutPlanDay>?> _showWorkoutPlanEditorSheet(
  BuildContext context, {
  required List<AtlasExercise> library,
  required List<_CustomWorkoutPlanDay> initialPlan,
}) {
  return showModalBottomSheet<List<_CustomWorkoutPlanDay>>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) =>
            _WorkoutPlanEditorSheet(library: library, initialPlan: initialPlan),
  );
}

class _WorkoutPlanEditorSheet extends StatefulWidget {
  const _WorkoutPlanEditorSheet({
    required this.library,
    required this.initialPlan,
  });

  final List<AtlasExercise> library;
  final List<_CustomWorkoutPlanDay> initialPlan;

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
                  onPressed: () => Navigator.pop(context, _plan),
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Save'),
                ),
              ],
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
              onChanged: (value) => day.name = value.trim(),
            ),
            const SizedBox(height: 8),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: day.isRestDay,
              onChanged:
                  (value) => setState(() {
                    day.isRestDay = value;
                    if (value) day.exercises.clear();
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
    setState(() => _plan[_selectedDay].exercises.add(picked));
  }

  void _moveExercise(int index, int direction) {
    final day = _plan[_selectedDay];
    final target = index + direction;
    if (target < 0 || target >= day.exercises.length) return;
    setState(() {
      final exercise = day.exercises.removeAt(index);
      day.exercises.insert(target, exercise);
    });
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
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AtlasColors.hairline),
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
    return Column(
      children: [
        for (final exercise in report.exercises) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AtlasColors.hairline),
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
                        '${exercise.totalSets} sets / ${exercise.totalReps} reps / ${exercise.totalVolume.toStringAsFixed(0)} kg',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.lock_outline_rounded,
                  color: AtlasColors.inkSoft,
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
                _HeroChip(label: '${report.totalSets} sets'),
                _HeroChip(label: '${report.totalReps} reps'),
                _HeroChip(
                  label: '${report.totalVolume.toStringAsFixed(0)} kg volume',
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
                                            alpha: 0.08,
                                          )
                                          : Colors.white.withValues(
                                            alpha: 0.68,
                                          ),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color:
                                        selectedRow
                                            ? AtlasColors.accent.withValues(
                                              alpha: 0.2,
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
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: AtlasColors.hairline),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AtlasColors.surfaceWarm,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AtlasColors.inkMuted,
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
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: AtlasColors.surfaceWarm.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (!isCardio) ...[
                Expanded(
                  child: Text(
                    'Sets',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  isCardio ? 'Minutes' : 'Reps',
                  textAlign: isCardio ? TextAlign.start : TextAlign.center,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isCardio ? 'Distance' : 'Kg',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (!isCardio) ...[
                _CompactStepper(
                  value: entry.sets,
                  onChanged: (value) {
                    entry.sets = value;
                    onChanged();
                  },
                ),
                const SizedBox(width: 10),
              ],
              _CompactStepper(
                value: entry.reps,
                onChanged: (value) {
                  entry.reps = value;
                  onChanged();
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InlineNumberField(
                  label: isCardio ? 'km' : '',
                  value: entry.weight,
                  onChanged: (value) {
                    entry.weight = value;
                    onChanged();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactStepper extends StatelessWidget {
  const _CompactStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AtlasColors.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              padding: EdgeInsets.zero,
              onPressed: () => onChanged((value - 1).clamp(1, 999)),
              icon: const Icon(Icons.remove_rounded),
            ),
            Text('$value', style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
              padding: EdgeInsets.zero,
              onPressed: () => onChanged((value + 1).clamp(1, 999)),
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
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
      weight = 0;

  _EditableWorkoutEntry.fromDraft(
    this.exercise, {
    required Object? sets,
    required Object? reps,
    required Object? weight,
  }) : sets =
           sets is num
               ? sets.round().clamp(1, 99).toInt()
               : _defaultSetsFor(exercise),
       reps =
           reps is num
               ? reps.round().clamp(1, 999).toInt()
               : _defaultRepsFor(exercise),
       weight = weight is num ? weight.toDouble().clamp(0, 9999).toDouble() : 0;

  AtlasExercise exercise;
  int sets;
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
  for (var index = 0; index < 5; index++) {
    final raw = rawPlan.firstWhere(
      (item) => item['dayNumber'] == index + 1,
      orElse: () => const {},
    );
    final exerciseIds = raw['exerciseIds'];
    loaded.add(
      _CustomWorkoutPlanDay(
        dayNumber: index + 1,
        name: raw['name'] as String? ?? defaults[index].name,
        isRestDay: raw['isRestDay'] as bool? ?? defaults[index].isRestDay,
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
    final index = source.dayNumber.clamp(1, 5) - 1;
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
                in plan[workout.dayNumber.clamp(1, 5) - 1].exercises)
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
