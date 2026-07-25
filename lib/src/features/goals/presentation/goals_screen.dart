import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_app_frame.dart';
import '../../../core/widgets/atlas_card.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/section_title.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AtlasAppFrame(
      subtitle: 'Quiet accountability',
      title: 'Goals',
      children: const [_GoalsEmptyCard(), _GoalTypesCard()],
    );
  }
}

class _GoalsEmptyCard extends StatelessWidget {
  const _GoalsEmptyCard();

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(24),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutBack,
              builder:
                  (context, value, child) =>
                      Transform.scale(scale: value, child: child),
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 110,
                color: AtlasColors.lilac.withValues(alpha: 0.08),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AtlasColors.lilac.withValues(alpha: 0.95),
                      AtlasColors.accent.withValues(alpha: 0.92),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AtlasColors.lilac.withValues(alpha: 0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: const Icon(Icons.flag_rounded, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                'No active goals yet',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Atlas will show goal health, progress bars, and milestones only after real goals are created.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              AtlasGradientButton(
                label: 'Create Goal coming soon',
                icon: Icons.add_rounded,
                colors: const [AtlasColors.lilac, AtlasColors.accent],
                onPressed:
                    () => showAtlasSnack(
                      context,
                      message:
                          'Goal creation is coming soon. No data was saved.',
                      icon: Icons.info_outline_rounded,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalTypesCard extends StatelessWidget {
  const _GoalTypesCard();

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
          const SectionTitle('Planned Goal Types'),
          const SizedBox(height: 8),
          Text(
            'These are product placeholders, not goals assigned to your account.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          for (final item in goalTypes) ...[
            AtlasPressable(
              onTap:
                  () => showAtlasSnack(
                    context,
                    message: '${item.$2} setup is coming soon.',
                    icon: Icons.info_outline_rounded,
                  ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 11),
                child: Row(
                  children: [
                    Icon(item.$1, color: AtlasColors.inkMuted, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.$2,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      'Not set',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AtlasColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
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
