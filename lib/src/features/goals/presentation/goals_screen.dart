import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/atlas_state_cards.dart';
import '../../../core/widgets/section_title.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Quiet accountability',
      title: 'Goals',
      children: const [
        _GoalSummaryCard(),
        _GoalList(),
        _MilestoneCard(),
        _GoalTemplateEmptyState(),
      ],
    );
  }
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          AnimatedProgressRing(
            progress: 0.74,
            size: 108,
            strokeWidth: 11,
            color: AtlasColors.accent,
            trackColor: AtlasColors.accentSoft,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('74%', style: Theme.of(context).textTheme.titleLarge),
                Text('aligned', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Goal Health'),
                const SizedBox(height: 8),
                Text(
                  'You are on pace for weight, strength, and habit targets this month.',
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

class _GoalList extends StatelessWidget {
  const _GoalList();

  static const goals = [
    _Goal(
      'Weight Goal',
      'Reach 74.5 kg',
      '76.4 kg now',
      0.68,
      AtlasColors.accent,
      Icons.monitor_weight_outlined,
    ),
    _Goal(
      'Strength Goal',
      'Bench 80 kg for 5',
      '72.5 kg current',
      0.58,
      AtlasColors.success,
      Icons.fitness_center_outlined,
    ),
    _Goal(
      'Habit Goal',
      '5 workouts weekly',
      '4 complete',
      0.8,
      AtlasColors.lilac,
      Icons.calendar_month_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Active Goals'),
        const SizedBox(height: 12),
        for (var index = 0; index < goals.length; index++) ...[
          _GoalCard(goal: goals[index]),
          if (index != goals.length - 1) const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});

  final _Goal goal;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(goal.icon, size: 19, color: goal.color),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      goal.caption,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Text(
                '${(goal.progress * 100).round()}%',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: goal.color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(goal.target, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 10),
          AtlasProgressBar(value: goal.progress, color: goal.color),
        ],
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  const _MilestoneCard();

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap: () => showCompletionCelebration(context),
      child: AtlasCard(
        isGlass: true,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AtlasColors.warningSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                color: AtlasColors.warning,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Next Milestone'),
                  const SizedBox(height: 6),
                  Text(
                    'Two more workouts complete your strongest month so far.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: AtlasColors.inkSoft),
          ],
        ),
      ),
    );
  }
}

class _GoalTemplateEmptyState extends StatelessWidget {
  const _GoalTemplateEmptyState();

  @override
  Widget build(BuildContext context) {
    return AtlasEmptyStateCard(
      icon: Icons.add_task_outlined,
      title: 'Goal Templates',
      body: 'Future templates for weight, strength, habit, and deadlines.',
      actionLabel: 'Preview template library',
      onAction:
          () => showAtlasSnack(context, message: 'Goal templates preview'),
    );
  }
}

class _Goal {
  const _Goal(
    this.title,
    this.target,
    this.caption,
    this.progress,
    this.color,
    this.icon,
  );

  final String title;
  final String target;
  final String caption;
  final double progress;
  final Color color;
  final IconData icon;
}
