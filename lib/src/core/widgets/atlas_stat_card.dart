import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import 'atlas_card.dart';

class AtlasStatCard extends StatelessWidget {
  const AtlasStatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.caption,
    this.color = AtlasColors.accent,
    super.key,
  });

  final String label;
  final String value;
  final String? caption;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AtlasCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 14),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 650),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Opacity(opacity: value, child: child);
            },
            child: Text(value, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (caption != null) ...[
            const SizedBox(height: 4),
            Text(caption!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
