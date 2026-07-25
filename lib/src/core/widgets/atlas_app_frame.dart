import 'package:flutter/material.dart';

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
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFBFAF7), Color(0xFFF6F4EF)],
        ),
      ),
      child: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
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
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.displaySmall,
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 112),
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
    );
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
      duration: Duration(milliseconds: 420 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
