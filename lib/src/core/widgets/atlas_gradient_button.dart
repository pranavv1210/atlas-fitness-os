import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';
import 'atlas_pressable.dart';

class AtlasGradientButton extends StatelessWidget {
  const AtlasGradientButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.colors = const [AtlasColors.accent, AtlasColors.accentDeep],
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap: onPressed,
      scale: 0.965,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        constraints: const BoxConstraints(minHeight: 58),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                onPressed == null
                    ? [
                      AtlasColors.inkSoft.withValues(alpha: 0.22),
                      AtlasColors.inkSoft.withValues(alpha: 0.12),
                    ]
                    : colors,
          ),
          boxShadow:
              onPressed == null
                  ? null
                  : [
                    BoxShadow(
                      color: colors.first.withValues(alpha: 0.32),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
