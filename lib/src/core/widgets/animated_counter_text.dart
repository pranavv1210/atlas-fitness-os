import 'package:flutter/material.dart';

class AnimatedCounterText extends StatelessWidget {
  const AnimatedCounterText({
    required this.value,
    required this.formatter,
    this.duration = const Duration(milliseconds: 850),
    this.style,
    super.key,
  });

  final double value;
  final String Function(double value) formatter;
  final Duration duration;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return Text(formatter(animatedValue), style: style);
      },
    );
  }
}
