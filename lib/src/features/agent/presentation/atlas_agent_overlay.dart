import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../data/atlas_agent_service.dart';

class AtlasAgentLauncher extends StatelessWidget {
  const AtlasAgentLauncher({
    required this.service,
    required this.screen,
    super.key,
  });

  final AtlasAgentService service;
  final String screen;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: 24,
      bottom: 88 + MediaQuery.paddingOf(context).bottom,
      child: _AgentOrb(
        onTap: () {
          HapticFeedback.mediumImpact();
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            barrierColor: Colors.black.withValues(alpha: 0.32),
            sheetAnimationStyle: AnimationStyle(
              duration: const Duration(milliseconds: 340),
              reverseDuration: const Duration(milliseconds: 240),
            ),
            builder:
                (context) =>
                    AtlasAgentSheet(service: service, initialScreen: screen),
          );
        },
      ),
    );
  }
}

class _AgentOrb extends StatelessWidget {
  const _AgentOrb({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Atlas Gym Buddy',
      child: GestureDetector(
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 1200),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            final lift = 2 * (1 - (value - 0.5).abs() * 2);
            return Transform.translate(
              offset: Offset(0, -lift),
              child: AnimatedScale(
                scale: 1,
                duration: const Duration(milliseconds: 220),
                child: child,
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: _buddyGradient,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.54),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AtlasColors.accent.withValues(alpha: 0.32),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: AtlasColors.success.withValues(alpha: 0.22),
                      blurRadius: 32,
                      offset: const Offset(-6, -6),
                    ),
                  ],
                ),
                child: const _PlateBuddyFace(size: 40),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AtlasAgentSheet extends StatefulWidget {
  const AtlasAgentSheet({
    required this.service,
    required this.initialScreen,
    super.key,
  });

  final AtlasAgentService service;
  final String initialScreen;

  @override
  State<AtlasAgentSheet> createState() => _AtlasAgentSheetState();
}

class _AtlasAgentSheetState extends State<AtlasAgentSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<AtlasAgentMessage> _messages = [
    const AtlasAgentMessage(
      role: AtlasAgentRole.assistant,
      content:
          'Yo, I am your Atlas gym buddy. I can read your workouts, goals, history, weight, hydration, and exercises. Ask me what to train, what improved, or what to fix.',
    ),
  ];
  List<String> _suggestions = const [
    'What are we hitting today?',
    'Rate my last workout',
    'I skipped yesterday',
    'Give me a rest day plan',
  ];
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? value]) async {
    final message = (value ?? _controller.text).trim();
    if (message.isEmpty || _sending) return;
    _controller.clear();
    setState(() {
      _sending = true;
      _messages.add(
        AtlasAgentMessage(role: AtlasAgentRole.user, content: message),
      );
    });
    _scrollToBottom();

    try {
      final reply = await widget.service.ask(
        message: message,
        screen: widget.initialScreen,
        history: _messages,
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          AtlasAgentMessage(
            role: AtlasAgentRole.assistant,
            content: reply.message,
          ),
        );
        if (reply.suggestions.isNotEmpty) {
          _suggestions = reply.suggestions;
        }
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      showAtlasSnack(
        context,
        message:
            'Atlas Buddy could not reach the coach backend. Check Supabase function logs.',
        icon: Icons.cloud_off_rounded,
      );
      setState(() {
        _messages.add(
          const AtlasAgentMessage(
            role: AtlasAgentRole.assistant,
            content:
                'Backend is not answering right now. Your app is fine, but the coach function needs a clean provider response.',
          ),
        );
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface =
        isDark
            ? const Color(0xF211141C)
            : AtlasColors.surfaceWarm.withValues(alpha: 0.94);
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(34)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.86,
                minHeight: MediaQuery.sizeOf(context).height * 0.58,
              ),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.62),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [const Color(0xF2141721), const Color(0xF20B0D13)]
                          : [
                            Colors.white.withValues(alpha: 0.98),
                            AtlasColors.cream.withValues(alpha: 0.9),
                          ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 34,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AtlasColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: _buddyGradient,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.58),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AtlasColors.accent.withValues(
                                    alpha: 0.24,
                                  ),
                                  blurRadius: 22,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const _PlateBuddyFace(size: 43),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Atlas Buddy',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                Text(
                                  'Trainer energy. Log brain. Zero fluff.',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        scrollDirection: Axis.horizontal,
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final suggestion = _suggestions[index];
                          return ActionChip(
                            onPressed:
                                _sending ? null : () => _send(suggestion),
                            label: Text(suggestion),
                            side: BorderSide(
                              color:
                                  isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : AtlasColors.hairline,
                            ),
                            backgroundColor:
                                isDark
                                    ? Colors.white.withValues(alpha: 0.06)
                                    : Colors.white.withValues(alpha: 0.7),
                            avatar: const Icon(Icons.bolt_rounded, size: 16),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
                        itemBuilder:
                            (context, index) =>
                                _AgentBubble(message: _messages[index]),
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemCount: _messages.length,
                      ),
                    ),
                    if (_sending)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: _ThinkingIndicator(),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: _AgentInput(
                        controller: _controller,
                        sending: _sending,
                        onSend: _send,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AgentBubble extends StatelessWidget {
  const _AgentBubble({required this.message});

  final AtlasAgentMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AtlasAgentRole.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color:
              isUser
                  ? AtlasColors.accent
                  : isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.white.withValues(alpha: 0.86),
          gradient:
              isUser
                  ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AtlasColors.accent, AtlasColors.accentDeep],
                  )
                  : null,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 6),
            bottomRight: Radius.circular(isUser ? 6 : 20),
          ),
          border: Border.all(
            color:
                isUser
                    ? Colors.white.withValues(alpha: 0.18)
                    : isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AtlasColors.hairline,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          message.content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isUser ? Colors.white : null,
            height: 1.45,
            fontWeight: isUser ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _AgentInput extends StatelessWidget {
  const _AgentInput({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final ValueChanged<String?> onSend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: !sending,
            minLines: 1,
            maxLines: 4,
            textInputAction: TextInputAction.send,
            onSubmitted: sending ? null : onSend,
            decoration: const InputDecoration(
              hintText: 'Ask your gym buddy...',
              prefixIcon: Icon(Icons.fitness_center_rounded),
            ),
          ),
        ),
        const SizedBox(width: 10),
        FilledButton(
          onPressed: sending ? null : () => onSend(null),
          style: FilledButton.styleFrom(
            minimumSize: const Size(56, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child:
              sending
                  ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Icon(Icons.arrow_upward_rounded),
        ),
      ],
    );
  }
}

const _buddyGradient = RadialGradient(
  center: Alignment.topLeft,
  radius: 1.2,
  colors: [
    Colors.white,
    AtlasColors.success,
    AtlasColors.accent,
    AtlasColors.accentDeep,
  ],
  stops: [0, 0.2, 0.66, 1],
);

class _PlateBuddyFace extends StatelessWidget {
  const _PlateBuddyFace({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        size: Size.square(size),
        painter: _PlateBuddyPainter(),
      ),
    );
  }
}

class _PlateBuddyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final platePaint =
        Paint()
          ..shader = const RadialGradient(
            center: Alignment.topLeft,
            radius: 1.1,
            colors: [Color(0xFFFFFFFF), Color(0xFFE9F0FF), Color(0xFF111827)],
            stops: [0, 0.24, 1],
          ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius, platePaint);

    final rim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.16
          ..color = Colors.white.withValues(alpha: 0.72);
    canvas.drawCircle(center, radius * 0.82, rim);

    final hole =
        Paint()..color = const Color(0xFF111827).withValues(alpha: 0.16);
    canvas.drawCircle(center, radius * 0.2, hole);

    final gripPaint =
        Paint()
          ..color = const Color(0xFF111827).withValues(alpha: 0.34)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = radius * 0.18;
    for (final angle in const [-1.55, 0.55, 2.65]) {
      final start =
          center +
          Offset(
            radius * 0.48 * math.cos(angle),
            radius * 0.48 * math.sin(angle),
          );
      final end =
          center +
          Offset(
            radius * 0.7 * math.cos(angle),
            radius * 0.7 * math.sin(angle),
          );
      canvas.drawLine(start, end, gripPaint);
    }

    final eyePaint = Paint()..color = const Color(0xFF111827);
    canvas.drawCircle(
      Offset(size.width * 0.39, size.height * 0.43),
      radius * 0.08,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.43),
      radius * 0.08,
      eyePaint,
    );

    final mouth =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.075
          ..strokeCap = StrokeCap.round
          ..color = const Color(0xFF111827);
    final mouthPath =
        Path()
          ..moveTo(size.width * 0.4, size.height * 0.58)
          ..quadraticBezierTo(
            size.width * 0.5,
            size.height * 0.68,
            size.width * 0.62,
            size.height * 0.58,
          );
    canvas.drawPath(mouthPath, mouth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ThinkingIndicator extends StatelessWidget {
  const _ThinkingIndicator();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Atlas is reading your logs...',
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AtlasColors.inkMuted,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
