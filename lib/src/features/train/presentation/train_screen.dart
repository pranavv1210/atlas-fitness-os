import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
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
  final List<_EditableWorkoutEntry> _entries = [];
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = AppScope.maybeRead(context)?.atlasDataRepository;
    _future ??= _load();
  }

  Future<AtlasDashboardSnapshot> _load() async {
    final snapshot =
        _repository == null
            ? emptyAtlasSnapshot()
            : await _repository!.loadSnapshot();
    _entries
      ..clear()
      ..addAll([
        for (final item in snapshot.templateExercises)
          _EditableWorkoutEntry.fromTemplate(item),
      ]);
    if (_entries.isEmpty && snapshot.exerciseLibrary.isNotEmpty) {
      _entries.add(_EditableWorkoutEntry(snapshot.exerciseLibrary.first));
    }
    return snapshot;
  }

  Future<void> _saveWorkout(AtlasDashboardSnapshot snapshot) async {
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

    setState(() => _saving = true);
    try {
      await repository.saveWorkout(
        day: workout,
        entries: [
          for (final entry in _entries)
            AtlasWorkoutEntry(
              exercise: entry.exercise,
              sets: entry.sets,
              reps: entry.reps,
              weight: entry.weight,
            ),
        ],
      );
      if (!mounted) return;
      showCompletionCelebration(context);
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? emptyAtlasSnapshot();
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
            ),
            _ExerciseLogger(
              library: data.exerciseLibrary,
              entries: _entries,
              onChanged: () => setState(() {}),
              onAdd:
                  data.exerciseLibrary.isEmpty
                      ? null
                      : () {
                        HapticFeedback.selectionClick();
                        setState(
                          () => _entries.add(
                            _EditableWorkoutEntry(data.exerciseLibrary.first),
                          ),
                        );
                      },
            ),
            const _CycleExplainer(),
          ],
        );
      },
    );
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero({
    required this.snapshot,
    required this.saving,
    required this.onSave,
  });

  final AtlasDashboardSnapshot snapshot;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final workout = snapshot.todayWorkout ?? snapshot.starterWorkout;
    final isFirst = !snapshot.hasWorkoutCycleStarted;
    final totalSets = snapshot.templateExercises.fold<int>(
      0,
      (sum, item) => sum + item.targetSets,
    );

    return AtlasCard(
      isGlass: true,
      radius: 34,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _AnimatedExerciseGlyph(size: 74),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isFirst ? 'First workout' : 'Today\'s workout',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      workout?.name ?? 'Choose your workout',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isFirst
                ? 'Save this session to anchor Atlas. Tomorrow continues with Back + Biceps, then the 5-day cycle repeats.'
                : workout?.focus ?? 'Log clean sets, reps, weight, and rest.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroChip(label: '${snapshot.templateExercises.length} moves'),
              _HeroChip(label: '$totalSets target sets'),
              _HeroChip(
                label:
                    isFirst
                        ? 'Cycle not started'
                        : 'Day ${workout?.dayNumber ?? 1}',
              ),
            ],
          ),
          const SizedBox(height: 22),
          AtlasGradientButton(
            label:
                saving
                    ? 'Saving'
                    : isFirst
                    ? 'Save First Workout'
                    : 'Complete Workout',
            icon: saving ? Icons.sync_rounded : Icons.check_rounded,
            colors: const [AtlasColors.success, AtlasColors.accent],
            onPressed: saving ? null : onSave,
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
    required this.onChanged,
    required this.onAdd,
  });

  final List<AtlasExercise> library;
  final List<_EditableWorkoutEntry> entries;
  final VoidCallback onChanged;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SectionTitle('Exercises'),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          const _EmptyExerciseCard()
        else
          for (var index = 0; index < entries.length; index++) ...[
            _ExerciseEditor(
              index: index + 1,
              entry: entries[index],
              library: library,
              onChanged: onChanged,
            ),
            if (index != entries.length - 1) const SizedBox(height: 14),
          ],
      ],
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
        'No exercises loaded yet. Check your Supabase seed data or connection.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _ExerciseEditor extends StatelessWidget {
  const _ExerciseEditor({
    required this.index,
    required this.entry,
    required this.library,
    required this.onChanged,
  });

  final int index;
  final _EditableWorkoutEntry entry;
  final List<AtlasExercise> library;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final visual = exerciseVisual(entry.exercise);
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AnimatedExerciseGlyph(visual: visual, index: index),
              const SizedBox(width: 14),
              Expanded(
                child: AtlasPressable(
                  onTap: () => _pickExercise(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.exercise.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${entry.exercise.primaryMuscle} / ${entry.exercise.equipment} / ${entry.exercise.difficulty}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _pickExercise(context),
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Choose exercise',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _NumberStepper(
                label: 'Sets',
                value: entry.sets,
                onChanged: (value) {
                  entry.sets = value;
                  onChanged();
                },
              ),
              const SizedBox(width: 10),
              _NumberStepper(
                label: 'Reps',
                value: entry.reps,
                onChanged: (value) {
                  entry.reps = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InlineNumberField(
                  label: 'Weight kg',
                  value: entry.weight,
                  onChanged: (value) {
                    entry.weight = value;
                    onChanged();
                  },
                ),
              ),
              const SizedBox(width: 10),
              _NumberStepper(
                label: 'Rest sec',
                value: entry.restSeconds,
                step: 15,
                min: 15,
                onChanged: (value) {
                  entry.restSeconds = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          AtlasProgressBar(
            value: entry.completion,
            color: visual.gradient.first,
          ),
        ],
      ),
    );
  }

  Future<void> _pickExercise(BuildContext context) async {
    final picked = await showModalBottomSheet<AtlasExercise>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder:
          (context) =>
              _ExercisePickerSheet(library: library, selected: entry.exercise),
    );
    if (picked == null) return;
    HapticFeedback.selectionClick();
    entry.exercise = picked;
    entry.sets = picked.defaultSets;
    entry.reps = _firstNumber(picked.defaultReps);
    onChanged();
  }
}

class _ExercisePickerSheet extends StatelessWidget {
  const _ExercisePickerSheet({required this.library, required this.selected});

  final List<AtlasExercise> library;
  final AtlasExercise selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        MediaQuery.paddingOf(context).bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Choose Exercise'),
          const SizedBox(height: 6),
          Text(
            'Radio selection with movement preview.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.68,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final exercise = library[index];
                final selectedRow = exercise == selected;
                return AtlasPressable(
                  onTap: () => Navigator.pop(context, exercise),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          selectedRow
                              ? AtlasColors.accent.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.68),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color:
                            selectedRow
                                ? AtlasColors.accent.withValues(alpha: 0.2)
                                : AtlasColors.hairline,
                      ),
                    ),
                    child: Row(
                      children: [
                        _AnimatedExerciseGlyph(
                          visual: exerciseVisual(exercise),
                          size: 58,
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${exercise.primaryMuscle} / ${exercise.equipment}',
                                style: Theme.of(context).textTheme.bodyMedium,
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
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: library.length,
            ),
          ),
        ],
      ),
    );
  }
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

class _NumberStepper extends StatelessWidget {
  const _NumberStepper({
    required this.label,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.min = 1,
  });

  final String label;
  final int value;
  final int step;
  final int min;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AtlasColors.surfaceWarm,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AtlasColors.hairline),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onChanged((value - step).clamp(min, 999)),
                  icon: const Icon(Icons.remove_rounded),
                ),
                Text('$value', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  onPressed: () => onChanged((value + step).clamp(min, 999)),
                  icon: const Icon(Icons.add_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InlineNumberField extends StatelessWidget {
  const _InlineNumberField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value == 0 ? '' : value.toStringAsFixed(1),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AtlasColors.surfaceWarm,
      ),
      onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
    );
  }
}

class _CycleExplainer extends StatelessWidget {
  const _CycleExplainer();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        'Cycle rule: your first saved workout becomes Day 1. Atlas then moves through Back + Biceps, Arms + Abs, Shoulders + Legs, Rest, and repeats.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _EditableWorkoutEntry {
  _EditableWorkoutEntry(this.exercise)
    : sets = exercise.defaultSets,
      reps = _firstNumber(exercise.defaultReps),
      restSeconds = 60,
      weight = 0;

  factory _EditableWorkoutEntry.fromTemplate(AtlasWorkoutExercise template) {
    return _EditableWorkoutEntry(template.exercise)
      ..sets = template.targetSets
      ..reps = _firstNumber(template.targetReps);
  }

  AtlasExercise exercise;
  int sets;
  int reps;
  int restSeconds;
  double weight;

  double get completion {
    final hasWeight = weight > 0 ? 0.25 : 0.0;
    return (0.35 + sets.clamp(1, 6) / 6 * 0.4 + hasWeight).clamp(0, 1);
  }
}

int _firstNumber(String value) {
  final match = RegExp(r'\d+').firstMatch(value);
  return int.tryParse(match?.group(0) ?? '') ?? 10;
}
