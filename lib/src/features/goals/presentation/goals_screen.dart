import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/di/app_scope.dart';
import '../../../core/widgets/animated_progress_ring.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_progress_bar.dart';
import '../../../core/widgets/section_title.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Future<List<AtlasGoal>>? _future;
  AtlasDataRepository? _repository;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repository = AppScope.maybeRead(context)?.atlasDataRepository;
    _future ??= _load();
  }

  Future<List<AtlasGoal>> _load() async {
    return _repository?.loadGoals() ?? const [];
  }

  void _refresh() {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AtlasGoal>>(
      future: _future,
      builder: (context, snapshot) {
        final goals = snapshot.data ?? const <AtlasGoal>[];
        final avg =
            goals.isEmpty
                ? 0.0
                : goals.map((goal) => goal.progress).reduce((a, b) => a + b) /
                    goals.length;
        return AtlasAppFrame(
          subtitle: 'Quiet accountability',
          title: 'Goals',
          children: [
            _GoalHero(
              progress: avg,
              goalCount: goals.length,
              onCreate: _showCreateGoal,
            ),
            if (goals.isEmpty)
              const _NoGoalsCard()
            else
              _GoalList(goals: goals),
            _GoalTypesCard(onCreate: _showCreateGoal),
          ],
        );
      },
    );
  }

  Future<void> _showCreateGoal() async {
    final repository = _repository;
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    var type = AtlasGoalType.habit;
    var unit = 'workouts';

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    22,
                    8,
                    22,
                    MediaQuery.viewInsetsOf(context).bottom + 24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionTitle('Create Goal'),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<AtlasGoalType>(
                        value: type,
                        decoration: const InputDecoration(labelText: 'Type'),
                        items: const [
                          DropdownMenuItem(
                            value: AtlasGoalType.weight,
                            child: Text('Weight'),
                          ),
                          DropdownMenuItem(
                            value: AtlasGoalType.strength,
                            child: Text('Strength'),
                          ),
                          DropdownMenuItem(
                            value: AtlasGoalType.habit,
                            child: Text('Habit'),
                          ),
                          DropdownMenuItem(
                            value: AtlasGoalType.deadline,
                            child: Text('Deadline'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }
                          setSheetState(() {
                            type = value;
                            unit = switch (value) {
                              AtlasGoalType.weight => 'kg',
                              AtlasGoalType.strength => 'kg',
                              AtlasGoalType.habit => 'workouts',
                              AtlasGoalType.deadline => 'done',
                            };
                          });
                        },
                      ),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Goal'),
                      ),
                      TextField(
                        controller: currentController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(labelText: 'Current $unit'),
                      ),
                      TextField(
                        controller: targetController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(labelText: 'Target $unit'),
                      ),
                      const SizedBox(height: 22),
                      AtlasGradientButton(
                        label: 'Save Goal',
                        icon: Icons.check_rounded,
                        colors: const [AtlasColors.lilac, AtlasColors.accent],
                        onPressed: () async {
                          final target = double.tryParse(targetController.text);
                          final current =
                              double.tryParse(currentController.text) ?? 0;
                          final title = titleController.text.trim();
                          if (repository == null ||
                              target == null ||
                              target <= 0 ||
                              title.isEmpty) {
                            return;
                          }
                          await repository.saveGoal(
                            type: type,
                            title: title,
                            targetValue: target,
                            unit: unit,
                            currentValue: current,
                          );
                          _refresh();
                          if (context.mounted) {
                            Navigator.pop(context);
                            showAtlasSnack(context, message: 'Goal saved.');
                          }
                        },
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

class _GoalHero extends StatelessWidget {
  const _GoalHero({
    required this.progress,
    required this.goalCount,
    required this.onCreate,
  });

  final double progress;
  final int goalCount;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          AnimatedProgressRing(
            progress: progress.clamp(0, 1),
            size: 112,
            strokeWidth: 11,
            color: AtlasColors.accent,
            center: Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.titleLarge,
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
                  goalCount == 0
                      ? 'Create your first target and Atlas will track progress here.'
                      : '$goalCount active goals are being tracked.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                AtlasGradientButton(
                  label: 'Create Goal',
                  icon: Icons.add_rounded,
                  colors: const [AtlasColors.lilac, AtlasColors.accent],
                  onPressed: onCreate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoGoalsCard extends StatelessWidget {
  const _NoGoalsCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Text(
        'No active goals yet. Use Create Goal to add weight, strength, habit, or deadline targets.',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _GoalList extends StatelessWidget {
  const _GoalList({required this.goals});

  final List<AtlasGoal> goals;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Active Goals'),
        const SizedBox(height: 12),
        for (final goal in goals) ...[
          AtlasCard(
            isGlass: true,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(_goalIcon(goal.type), color: _goalColor(goal.type)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${(goal.progress * 100).round()}%',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: _goalColor(goal.type),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${goal.currentValue?.toStringAsFixed(1) ?? '0'} / ${goal.targetValue?.toStringAsFixed(1) ?? '-'} ${goal.targetUnit ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                AtlasProgressBar(
                  value: goal.progress,
                  color: _goalColor(goal.type),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _GoalTypesCard extends StatelessWidget {
  const _GoalTypesCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final goalTypes = [
      (Icons.monitor_weight_outlined, 'Weight goal'),
      (Icons.fitness_center_rounded, 'Strength goal'),
      (Icons.calendar_month_rounded, 'Habit goal'),
    ];

    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('Goal Types'),
          const SizedBox(height: 8),
          Text(
            'Create targets that Atlas can track from your logs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final item in goalTypes) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.$1, color: AtlasColors.inkMuted),
              title: Text(item.$2),
              trailing: const Icon(Icons.add_rounded),
              onTap: onCreate,
            ),
            if (item != goalTypes.last)
              const Divider(
                height: 1,
                thickness: 1,
                color: AtlasColors.hairline,
              ),
          ],
        ],
      ),
    );
  }
}

IconData _goalIcon(AtlasGoalType type) {
  return switch (type) {
    AtlasGoalType.weight => Icons.monitor_weight_outlined,
    AtlasGoalType.strength => Icons.fitness_center_rounded,
    AtlasGoalType.habit => Icons.calendar_month_rounded,
    AtlasGoalType.deadline => Icons.flag_rounded,
  };
}

Color _goalColor(AtlasGoalType type) {
  return switch (type) {
    AtlasGoalType.weight => AtlasColors.accent,
    AtlasGoalType.strength => AtlasColors.success,
    AtlasGoalType.habit => AtlasColors.lilac,
    AtlasGoalType.deadline => AtlasColors.warning,
  };
}
