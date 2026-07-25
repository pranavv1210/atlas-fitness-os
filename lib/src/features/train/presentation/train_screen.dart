import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';

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
    final repository = _repository;
    final snapshot =
        repository == null
            ? _fallbackSnapshot()
            : await repository.loadSnapshot();
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
    if (repository == null) {
      showAtlasSnack(
        context,
        message: 'Sign in is required before saving workout data.',
        icon: Icons.info_outline_rounded,
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await repository.saveWorkout(
        day: snapshot.todayWorkout,
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
      if (!mounted) {
        return;
      }
      showCompletionCelebration(context);
      setState(() => _future = _load());
    } catch (error) {
      if (!mounted) {
        return;
      }
      showAtlasSnack(
        context,
        message: 'Workout could not be saved. Check your connection.',
        icon: Icons.error_outline_rounded,
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AtlasDashboardSnapshot>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? _fallbackSnapshot();
        return AtlasAppFrame(
          subtitle: 'Day ${data.todayWorkout.dayNumber} of 5',
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
                  () => setState(
                    () => _entries.add(
                      _EditableWorkoutEntry(data.exerciseLibrary.first),
                    ),
                  ),
            ),
            const _CycleCard(),
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
    final totalSets = snapshot.templateExercises.fold<int>(
      0,
      (sum, item) => sum + item.targetSets,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: AtlasCard(
        isGlass: true,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AtlasColors.success, AtlasColors.accent],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AtlasColors.success.withValues(alpha: 0.22),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today\'s Workout',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        snapshot.todayWorkout.name,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              snapshot.todayWorkout.focus,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _HeroChip(
                  label: '${snapshot.templateExercises.length} exercises',
                  icon: Icons.list_alt_rounded,
                ),
                const SizedBox(width: 10),
                _HeroChip(label: '$totalSets sets', icon: Icons.repeat_rounded),
              ],
            ),
            const SizedBox(height: 22),
            AtlasGradientButton(
              label: saving ? 'Saving Workout' : 'Complete Workout',
              icon: saving ? Icons.sync_rounded : Icons.check_rounded,
              colors: const [AtlasColors.success, AtlasColors.accent],
              onPressed: saving ? null : onSave,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AtlasColors.hairline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AtlasColors.inkMuted),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ),
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
  final VoidCallback onAdd;

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
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ExerciseVisual(visual: visual, index: index),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<AtlasExercise>(
                      value: entry.exercise,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Exercise',
                      ),
                      items: [
                        for (final exercise in library)
                          DropdownMenuItem(
                            value: exercise,
                            child: Text(exercise.name),
                          ),
                      ],
                      onChanged: (exercise) {
                        if (exercise == null) {
                          return;
                        }
                        entry.exercise = exercise;
                        entry.sets = exercise.defaultSets;
                        entry.reps = _firstNumber(exercise.defaultReps);
                        onChanged();
                      },
                    ),
                    Text(
                      visual.cue,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
              const SizedBox(width: 10),
              _WeightField(
                value: entry.weight,
                onChanged: (value) {
                  entry.weight = value;
                  onChanged();
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          AtlasProgressBar(
            value: entry.sets.clamp(1, 6) / 6,
            color: visual.gradient.first,
          ),
        ],
      ),
    );
  }
}

class _ExerciseVisual extends StatelessWidget {
  const _ExerciseVisual({required this.visual, required this.index});

  final ExerciseVisual visual;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 950),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, -3 * (1 - (value - 0.5).abs() * 2)),
          child: child,
        );
      },
      child: Container(
        width: 72,
        height: 96,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: visual.gradient),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: visual.gradient.first.withValues(alpha: 0.26),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 8,
              child: Text(
                '$index',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.64),
                ),
              ),
            ),
            Center(child: Icon(visual.icon, color: Colors.white, size: 34)),
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
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AtlasColors.surfaceWarm,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AtlasColors.hairline),
        ),
        child: Column(
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => onChanged((value - 1).clamp(1, 99)),
                  icon: const Icon(Icons.remove_rounded),
                ),
                Text('$value', style: Theme.of(context).textTheme.titleMedium),
                IconButton(
                  onPressed: () => onChanged((value + 1).clamp(1, 99)),
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

class _WeightField extends StatelessWidget {
  const _WeightField({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        initialValue: value == 0 ? '' : value.toStringAsFixed(1),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Kg'),
        onChanged: (value) => onChanged(double.tryParse(value) ?? 0),
      ),
    );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Workout Cycle Logic'),
          const SizedBox(height: 8),
          Text(
            'Atlas follows Day 1 through Day 5 automatically from your profile anchor date: Chest + Triceps, Back + Biceps, Arms + Abs, Shoulders + Legs, Rest, then repeats.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EditableWorkoutEntry {
  _EditableWorkoutEntry(this.exercise)
    : sets = exercise.defaultSets,
      reps = _firstNumber(exercise.defaultReps),
      weight = 0;

  factory _EditableWorkoutEntry.fromTemplate(AtlasWorkoutExercise template) {
    return _EditableWorkoutEntry(template.exercise)
      ..sets = template.targetSets
      ..reps = _firstNumber(template.targetReps);
  }

  AtlasExercise exercise;
  int sets;
  int reps;
  double weight;
}

int _firstNumber(String value) {
  final match = RegExp(r'\d+').firstMatch(value);
  return int.tryParse(match?.group(0) ?? '') ?? 10;
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
