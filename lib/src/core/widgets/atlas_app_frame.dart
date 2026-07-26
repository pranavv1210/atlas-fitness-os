import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/theme/atlas_colors.dart';

class AtlasAppFrame extends StatelessWidget {
  const AtlasAppFrame({
    required this.title,
    required this.subtitle,
    required this.children,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: _AtlasAtmosphere()),
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 18),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subtitle,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: AtlasColors.inkMuted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              title,
                              style: Theme.of(context).textTheme.displayMedium
                                  ?.copyWith(fontSize: 52, height: 0.98),
                            ),
                          ],
                        ),
                      ),
                      if (trailing != null) ...[
                        const SizedBox(width: 16),
                        trailing!,
                      ],
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 126),
                sliver: SliverList.separated(
                  itemBuilder:
                      (context, index) => _Entrance(
                        delay: Duration(milliseconds: 55 * index),
                        child: children[index],
                      ),
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemCount: children.length,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AtlasAtmosphere extends StatelessWidget {
  const _AtlasAtmosphere();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? const Color(0xFF08090D) : AtlasColors.background,
            isDark ? const Color(0xFF10131A) : AtlasColors.cream,
            isDark ? const Color(0xFF151823) : AtlasColors.pearl,
          ],
        ),
      ),
      child: CustomPaint(painter: _AtmospherePainter(isDark: isDark)),
    );
  }
}

class _AtmospherePainter extends CustomPainter {
  const _AtmospherePainter({required this.isDark});

  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final bandPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.52),
              AtlasColors.accent.withValues(alpha: isDark ? 0.12 : 0.035),
              Colors.white.withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size);

    final path =
        Path()
          ..moveTo(0, size.height * 0.08)
          ..cubicTo(
            size.width * 0.38,
            size.height * 0.02,
            size.width * 0.68,
            size.height * 0.22,
            size.width,
            size.height * 0.14,
          )
          ..lineTo(size.width, size.height * 0.34)
          ..cubicTo(
            size.width * 0.62,
            size.height * 0.43,
            size.width * 0.35,
            size.height * 0.18,
            0,
            size.height * 0.28,
          )
          ..close();
    canvas.drawPath(path, bandPaint);

    final grain =
        Paint()..color = Colors.white.withValues(alpha: isDark ? 0.035 : 0.07);
    const step = 19.0;
    for (var y = 0.0; y < size.height; y += step) {
      for (var x = 0.0; x < size.width; x += step) {
        final phase = math.sin(x * 0.11 + y * 0.07);
        canvas.drawCircle(Offset(x, y), phase.abs() * 0.42, grain);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AtmospherePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.child, required this.delay});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 520 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final bounded = value.clamp(0.0, 1.0);
        return Opacity(
          opacity: bounded,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - bounded)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
