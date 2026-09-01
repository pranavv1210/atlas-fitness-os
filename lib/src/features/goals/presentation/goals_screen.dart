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
import '../../../core/services/atlas_notification_service.dart';
import '../../atlas/data/atlas_data_repository.dart';
import '../../atlas/data/atlas_models.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({this.onBack, super.key});

  final VoidCallback? onBack;

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  Future<List<AtlasGoal>>? _future;
  AtlasDataRepository? _repository;
  AtlasNotificationService? _notificationService;
  bool _notificationsEnabled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dependencies = AppScope.maybeRead(context);
    _repository = dependencies?.atlasDataRepository;
    _notificationService = dependencies?.notificationService;
    _notificationsEnabled =
        dependencies?.preferences.notificationEnabled ?? false;
    _future ??= _load();
  }

  Future<List<AtlasGoal>> _load() async {
    final goals =
        await (_repository?.loadGoals() ?? Future.value(const <AtlasGoal>[]));
    await _syncGoalReminders(goals);
    return goals;
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
          subtitle: '',
          title: 'Goals',
          onBack: widget.onBack,
          children: [
            _GoalHero(
              progress: avg,
              goalCount: goals.length,
              onCreate: () => _showCreateGoal(AtlasGoalType.habit),
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

  Future<void> _syncGoalReminders(List<AtlasGoal> goals) async {
    final notificationService = _notificationService;
    if (notificationService == null || !_notificationsEnabled) {
      return;
    }
    final activeIncompleteCount =
        goals.where((goal) => goal.progress < 1).length;
    if (activeIncompleteCount == 0) {
      await notificationService.cancelGoalReminders();
      return;
    }
    await notificationService.scheduleGoalReminders(
      activeGoalCount: activeIncompleteCount,
    );
  }

  Future<void> _showCreateGoal(AtlasGoalType initialType) async {
    final repository = _repository;
    final titleController = TextEditingController();
    final targetController = TextEditingController();
    final currentController = TextEditingController(text: '0');
    var type = initialType;
    var spec = _goalSpec(type);
    titleController.text = spec.defaultTitle;
    targetController.text = spec.defaultTarget;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setSheetState) => SafeArea(
                  child: SingleChildScrollView(
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
                        const SizedBox(height: 8),
                        Text(
                          spec.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final option in const [
                              AtlasGoalType.weight,
                              AtlasGoalType.strength,
                              AtlasGoalType.habit,
                            ])
                              ChoiceChip(
                                selected: type == option,
                                label: Text(_goalSpec(option).shortTitle),
                                avatar: Icon(_goalIcon(option), size: 18),
                                onSelected: (_) {
                                  setSheetState(() {
                                    type = option;
                                    spec = _goalSpec(option);
                                    titleController.text = spec.defaultTitle;
                                    targetController.text = spec.defaultTarget;
                                    currentController.text = '0';
                                  });
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        _GoalInput(
                          label: spec.titleLabel,
                          helper: spec.titleHelp,
                          child: TextField(
                            controller: titleController,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: spec.titleHint,
                            ),
                          ),
                        ),
                        _GoalInput(
                          label: spec.currentLabel,
                          helper: spec.currentHelp,
                          child: TextField(
                            controller: currentController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              hintText: spec.currentHint,
                              suffixText: spec.unit,
                            ),
                          ),
                        ),
                        _GoalInput(
                          label: spec.targetLabel,
                          helper: spec.targetHelp,
                          child: TextField(
                            controller: targetController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: InputDecoration(
                              hintText: spec.targetHint,
                              suffixText: spec.unit,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        AtlasGradientButton(
                          label: 'Save ${spec.shortTitle}',
                          icon: Icons.check_rounded,
                          colors: [_goalColor(type), AtlasColors.accent],
                          onPressed: () async {
                            final target = double.tryParse(
                              targetController.text,
                            );
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
                              unit: spec.unit,
                              currentValue: current,
                            );
                            _refresh();
                            await _syncGoalReminders(await _load());
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
                const SectionTitle('Goal Progress'),
                const SizedBox(height: 8),
                Text(
                  goalCount == 0
                      ? 'Create a target for body weight, strength, or weekly training. Atlas will show progress here.'
                      : '$goalCount active ${goalCount == 1 ? 'goal is' : 'goals are'} still in progress.',
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
        'No active goals yet. Choose a goal type below: body weight, lift strength, or weekly training habit.',
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

  final ValueChanged<AtlasGoalType> onCreate;

  @override
  Widget build(BuildContext context) {
    final goalTypes = [
      _goalSpec(AtlasGoalType.weight),
      _goalSpec(AtlasGoalType.strength),
      _goalSpec(AtlasGoalType.habit),
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
            'Pick what you want Atlas to track. Each type asks for only the details it needs.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final item in goalTypes) ...[
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.icon, color: item.color),
              title: Text(item.title),
              subtitle: Text(item.description),
              trailing: const Icon(Icons.add_rounded),
              onTap: () => onCreate(item.type),
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

class _GoalInput extends StatelessWidget {
  const _GoalInput({
    required this.label,
    required this.helper,
    required this.child,
  });

  final String label;
  final String helper;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 5),
          Text(helper, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _GoalSpec {
  const _GoalSpec({
    required this.type,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.unit,
    required this.defaultTitle,
    required this.defaultTarget,
    required this.titleLabel,
    required this.titleHelp,
    required this.titleHint,
    required this.currentLabel,
    required this.currentHelp,
    required this.currentHint,
    required this.targetLabel,
    required this.targetHelp,
    required this.targetHint,
  });

  final AtlasGoalType type;
  final String title;
  final String shortTitle;
  final String description;
  final IconData icon;
  final Color color;
  final String unit;
  final String defaultTitle;
  final String defaultTarget;
  final String titleLabel;
  final String titleHelp;
  final String titleHint;
  final String currentLabel;
  final String currentHelp;
  final String currentHint;
  final String targetLabel;
  final String targetHelp;
  final String targetHint;
}

_GoalSpec _goalSpec(AtlasGoalType type) {
  return switch (type) {
    AtlasGoalType.weight => const _GoalSpec(
      type: AtlasGoalType.weight,
      title: 'Weight goal',
      shortTitle: 'Weight',
      description: 'Track a body-weight target from your daily weight logs.',
      icon: Icons.monitor_weight_outlined,
      color: AtlasColors.accent,
      unit: 'kg',
      defaultTitle: 'Reach target body weight',
      defaultTarget: '',
      titleLabel: 'Goal name',
      titleHelp: 'Example: Cut to 72 kg or reach 80 kg.',
      titleHint: 'Reach target body weight',
      currentLabel: 'Current body weight',
      currentHelp:
          'Enter your latest weight. Future weight logs update progress.',
      currentHint: '74.5',
      targetLabel: 'Target body weight',
      targetHelp: 'The weight you want to reach.',
      targetHint: '72',
    ),
    AtlasGoalType.strength => const _GoalSpec(
      type: AtlasGoalType.strength,
      title: 'Strength goal',
      shortTitle: 'Strength',
      description:
          'Track a target lift or working weight from your training logs.',
      icon: Icons.fitness_center_rounded,
      color: AtlasColors.success,
      unit: 'kg',
      defaultTitle: 'Increase a lift',
      defaultTarget: '',
      titleLabel: 'Lift or exercise',
      titleHelp: 'Example: Bench press, squat, shoulder press.',
      titleHint: 'Bench press',
      currentLabel: 'Current best',
      currentHelp: 'Your current working weight for this lift.',
      currentHint: '40',
      targetLabel: 'Target weight',
      targetHelp: 'The working weight you want to hit.',
      targetHint: '60',
    ),
    AtlasGoalType.habit => const _GoalSpec(
      type: AtlasGoalType.habit,
      title: 'Habit goal',
      shortTitle: 'Habit',
      description:
          'Track weekly consistency, such as workouts completed each week.',
      icon: Icons.calendar_month_rounded,
      color: AtlasColors.lilac,
      unit: 'workouts/week',
      defaultTitle: 'Train consistently',
      defaultTarget: '5',
      titleLabel: 'Habit name',
      titleHelp: 'Example: Train 5 days every week.',
      titleHint: 'Train consistently',
      currentLabel: 'Current weekly count',
      currentHelp: 'How many workouts you have completed this week.',
      currentHint: '0',
      targetLabel: 'Weekly target',
      targetHelp: 'How many workouts should complete the habit.',
      targetHint: '5',
    ),
    AtlasGoalType.deadline => const _GoalSpec(
      type: AtlasGoalType.deadline,
      title: 'Deadline goal',
      shortTitle: 'Deadline',
      description: 'Track a target that has a finish line.',
      icon: Icons.flag_rounded,
      color: AtlasColors.warning,
      unit: 'done',
      defaultTitle: 'Finish target',
      defaultTarget: '1',
      titleLabel: 'Goal name',
      titleHelp: 'Name the deadline target.',
      titleHint: 'Finish target',
      currentLabel: 'Current progress',
      currentHelp: 'Use 0 if it has not started.',
      currentHint: '0',
      targetLabel: 'Target',
      targetHelp: 'Use 1 when the target is done.',
      targetHint: '1',
    ),
  };
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
