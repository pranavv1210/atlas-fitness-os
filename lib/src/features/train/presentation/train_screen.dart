import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/section_title.dart';

class TrainScreen extends StatelessWidget {
  const TrainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Workout foundation',
      title: 'Train',
      children: const [
        _WorkoutEmptyCard(),
        _DefaultCycleCard(),
        _ExerciseLibraryEmptyCard(),
      ],
    );
  }
}

class _WorkoutEmptyCard extends StatelessWidget {
  const _WorkoutEmptyCard();

  @override
  Widget build(BuildContext context) {
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
                    Colors.white.withValues(alpha: 0.94),
                    AtlasColors.successSoft.withValues(alpha: 0.84),
                    AtlasColors.accentSoft.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          AtlasCard(
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
                        color: Colors.white.withValues(alpha: 0.72),
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
                        color: AtlasColors.success,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        'Workout logging not connected yet',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'No exercises, sets, reps, or workout history have been created for this account. This screen will become dynamic when logging is implemented.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                AtlasGradientButton(
                  label: 'Start Workout coming soon',
                  icon: Icons.play_arrow_rounded,
                  colors: const [AtlasColors.success, AtlasColors.accent],
                  onPressed:
                      () => showAtlasSnack(
                        context,
                        message:
                            'Start Workout is disabled until real logging exists.',
                        icon: Icons.info_outline_rounded,
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

class _DefaultCycleCard extends StatelessWidget {
  const _DefaultCycleCard();

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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Default Workout Cycle'),
          const SizedBox(height: 8),
          Text(
            'This is the planned routine from your Atlas brief, not logged workout data.',
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
          const SizedBox(height: 18),
          const AtlasProgressBar(
            value: 0,
            semanticLabel: 'No workout progress logged yet',
          ),
        ],
      ),
    );
  }
}

class _ExerciseLibraryEmptyCard extends StatelessWidget {
  const _ExerciseLibraryEmptyCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AtlasColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.library_books_outlined,
              color: AtlasColors.accent,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Exercise Library'),
                const SizedBox(height: 6),
                Text(
                  'Exercise selection will appear after the real library is connected.',
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
