import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/atlas_colors.dart';
import 'atlas_progress_bar.dart';
import 'section_title.dart';

void showAtlasSnack(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_outline,
}) {
  HapticFeedback.lightImpact();
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 19),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

Future<void> showWorkoutPreviewSheet(BuildContext context) {
  final rootContext = context;
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Workout Preview'),
            const SizedBox(height: 8),
            Text(
              'Workout preview will be available after real workout logging is implemented.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            const _PreviewRow(label: 'Workout', value: 'Not created'),
            const _PreviewRow(label: 'Sets', value: 'No data yet'),
            const _PreviewRow(label: 'Status', value: 'Coming soon'),
            const SizedBox(height: 18),
            const AtlasProgressBar(value: 0, color: AtlasColors.success),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                showAtlasSnack(
                  rootContext,
                  message: 'Workout preview is coming soon. No data was saved.',
                  icon: Icons.info_outline_rounded,
                );
              },
              child: const Text('Continue'),
            ),
          ],
        ),
      );
    },
  );
}

Future<void> showCompletionCelebration(BuildContext context) {
  HapticFeedback.heavyImpact();
  return showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              const _CelebrationBurst(),
              const SizedBox(height: 18),
              Text(
                'Workout Complete',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'A restrained success moment for future completion flow.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _PreviewRow extends StatelessWidget {
  const _PreviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _CelebrationBurst extends StatelessWidget {
  const _CelebrationBurst();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.elasticOut,
      builder: (context, value, _) {
        return SizedBox.square(
          dimension: 112,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (var index = 0; index < 10; index++)
                Transform.translate(
                  offset: Offset.fromDirection(
                    math.pi * 2 * index / 10,
                    38 * value,
                  ),
                  child: Container(
                    width: 7 + (index % 3) * 2,
                    height: 7 + (index % 3) * 2,
                    decoration: BoxDecoration(
                      color: [
                        AtlasColors.accent,
                        AtlasColors.success,
                        AtlasColors.warning,
                        AtlasColors.lilac,
                      ][index % 4].withValues(alpha: 0.78),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Transform.scale(
                scale: 0.72 + value * 0.28,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: const BoxDecoration(
                    color: AtlasColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
