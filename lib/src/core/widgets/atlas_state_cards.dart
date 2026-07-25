import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import 'atlas_card.dart';
import 'atlas_pressable.dart';
import 'section_title.dart';

class AtlasLoadingStateCard extends StatelessWidget {
  const AtlasLoadingStateCard({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SkeletonBox(width: 42, height: 42),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _SkeletonBox(width: 150, height: 14),
                    SizedBox(height: 9),
                    _SkeletonBox(width: 210, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SectionTitle(title),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class AtlasEmptyStateCard extends StatelessWidget {
  const AtlasEmptyStateCard({
    required this.icon,
    required this.title,
    required this.body,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      isGlass: true,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AtlasColors.accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AtlasColors.accent, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(title),
                const SizedBox(height: 6),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
                if (actionLabel != null) ...[
                  const SizedBox(height: 14),
                  AtlasPressable(
                    onTap: onAction,
                    child: Text(
                      actionLabel!,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AtlasColors.accent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AtlasErrorStateCard extends StatelessWidget {
  const AtlasErrorStateCard({
    required this.title,
    required this.body,
    super.key,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(18),
      color: AtlasColors.roseSoft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AtlasColors.rose),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 5),
                Text(body, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.78),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (context, value, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AtlasColors.surfaceMuted.withValues(alpha: value),
            borderRadius: BorderRadius.circular(8),
          ),
        );
      },
    );
  }
}
