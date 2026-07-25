import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AtlasPressable extends StatefulWidget {
  const AtlasPressable({
    required this.child,
    this.onTap,
    this.scale = 0.98,
    this.enableHaptics = true,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool enableHaptics;

  @override
  State<AtlasPressable> createState() => _AtlasPressableState();
}

class _AtlasPressableState extends State<AtlasPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) {
          if (widget.onTap != null && widget.enableHaptics) {
            HapticFeedback.selectionClick();
          }
          setState(() => _isPressed = true);
        },
        onTapCancel: () => setState(() => _isPressed = false),
        onTapUp: (_) => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed && widget.onTap != null ? widget.scale : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          child: AnimatedOpacity(
            opacity: widget.onTap == null ? 0.62 : 1,
            duration: const Duration(milliseconds: 180),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
