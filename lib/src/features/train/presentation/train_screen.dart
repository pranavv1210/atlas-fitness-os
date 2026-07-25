import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/section_title.dart';

class TrainScreen extends StatelessWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Chest + Triceps',
      title: 'Train',
      children: const [_WorkoutHero(), _ExerciseList(), _WorkoutCyclePreview()],
    );
  }
}

class _WorkoutHero extends StatelessWidget {
  const _WorkoutHero();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedProgressRing(
                progress: 0.72,
                size: 96,
                strokeWidth: 10,
                color: AtlasColors.success,
                trackColor: AtlasColors.successSoft,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('18', style: Theme.of(context).textTheme.titleLarge),
                    Text('sets', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s Workout',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Chest + Triceps',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '6 exercises / 58 min / moderate load',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => showWorkoutPreviewSheet(context),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Start Workout'),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 54,
                height: 52,
                child: AtlasPressable(
                  onTap: () => showCompletionCelebration(context),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AtlasColors.successSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: AtlasColors.success,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Completion animation preview only',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _ExerciseList extends StatelessWidget {
  const _ExerciseList();

  static const exercises = [
    _Exercise('Barbell Bench Press', '4 sets', '8-10 reps', 'Main lift'),
    _Exercise('Incline Dumbbell Press', '3 sets', '10 reps', 'Controlled'),
    _Exercise('Cable Fly', '3 sets', '12-15 reps', 'Stretch'),
    _Exercise('Dips', '3 sets', '8-12 reps', 'Chest lean'),
    _Exercise('Rope Pushdown', '3 sets', '12 reps', 'Full lockout'),
    _Exercise('Overhead Extension', '2 sets', '12-15 reps', 'Slow eccentric'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Exercises'),
        const SizedBox(height: 12),
        for (var index = 0; index < exercises.length; index++) ...[
          _ExerciseCard(index: index + 1, exercise: exercises[index]),
          if (index != exercises.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.index, required this.exercise});

  final int index;
  final _Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap:
          () => showAtlasSnack(
            context,
            message: '${exercise.name} selection preview',
          ),
      child: AtlasCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AtlasColors.accentSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$index',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AtlasColors.accent),
              ),
            ),
            const SizedBox(width: 14),
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
                    exercise.note,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  exercise.sets,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 5),
                Text(
                  exercise.reps,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCyclePreview extends StatelessWidget {
  const _WorkoutCyclePreview();

  @override
  Widget build(BuildContext context) {
    const days = [
      ('D1', 'Chest + Triceps', 1.0, AtlasColors.accent),
      ('D2', 'Back + Biceps', 0.0, AtlasColors.inkSoft),
      ('D3', 'Arms + Abs', 0.0, AtlasColors.inkSoft),
      ('D4', 'Shoulders + Legs', 0.0, AtlasColors.inkSoft),
      ('D5', 'Rest', 0.0, AtlasColors.inkSoft),
    ];

    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Workout Cycle'),
          const SizedBox(height: 16),
          for (final day in days) ...[
            Row(
              children: [
                SizedBox(
                  width: 34,
                  child: Text(
                    day.$1,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: day.$4),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 7),
                      AtlasProgressBar(
                        value: day.$3,
                        color: day.$4,
                        trackColor: AtlasColors.surfaceMuted,
                        height: 5,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (day != days.last) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _Exercise {
  const _Exercise(this.name, this.sets, this.reps, this.note);

  final String name;
  final String sets;
  final String reps;
  final String note;
}
