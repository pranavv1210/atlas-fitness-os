import 'dart:ui';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/services/atlas_preferences.dart';
import '../../../core/widgets/atlas_feedback.dart';
import '../data/atlas_agent_service.dart';

class AtlasAgentLauncher extends StatefulWidget {
  const AtlasAgentLauncher({
    required this.service,
    required this.preferences,
    required this.screen,
    super.key,
  });

  final AtlasAgentService service;
  final AtlasPreferences preferences;
  final String screen;

  @override
  State<AtlasAgentLauncher> createState() => _AtlasAgentLauncherState();
}

class _AtlasAgentLauncherState extends State<AtlasAgentLauncher> {
  static const _orbSize = 68.0;
  Offset? _position;
  bool _dragging = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position ??= _initialPosition(MediaQuery.sizeOf(context));
  }

  Offset _initialPosition(Size size) {
    final savedX = widget.preferences.agentOrbX;
    final savedY = widget.preferences.agentOrbY;
    if (savedX != null && savedY != null) {
      return Offset(savedX * size.width, savedY * size.height);
    }
    return Offset(size.width - _orbSize - 18, size.height - _orbSize - 120);
  }

  Offset _clampPosition(Offset position, Size size) {
    final padding = MediaQuery.paddingOf(context);
    final minY = padding.top + 16;
    final maxY = size.height - padding.bottom - _orbSize - 92;
    return Offset(
      position.dx.clamp(12, size.width - _orbSize - 12),
      position.dy.clamp(minY, maxY),
    );
  }

  Offset _snapToNearestSide(Offset position, Size size) {
    final clamped = _clampPosition(position, size);
    final left = 12.0;
    final right = size.width - _orbSize - 12;
    final targetX = clamped.dx + (_orbSize / 2) < size.width / 2 ? left : right;
    return Offset(targetX, clamped.dy);
  }

  Future<void> _savePosition(Size size) async {
    final position = _position;
    if (position == null) return;
    await widget.preferences.setAgentOrbPosition(
      position.dx / size.width,
      position.dy / size.height,
    );
  }

  void _openSheet() {
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
          (context) => AtlasAgentSheet(
            service: widget.service,
            initialScreen: widget.screen,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rawPosition = _position ?? _initialPosition(size);
    final position =
        _dragging
            ? _clampPosition(rawPosition, size)
            : _snapToNearestSide(rawPosition, size);
    _position = position;
    return AnimatedPositioned(
      left: position.dx,
      top: position.dy,
      duration: _dragging ? Duration.zero : const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTap: _openSheet,
        onPanStart: (_) => setState(() => _dragging = true),
        onPanUpdate:
            (details) => setState(() {
              _position = _clampPosition(position + details.delta, size);
            }),
        onPanEnd: (_) {
          HapticFeedback.selectionClick();
          setState(() {
            _dragging = false;
            _position = _snapToNearestSide(_position ?? position, size);
          });
          _savePosition(size);
        },
        child: const _AgentOrb(),
      ),
    );
  }
}

class _AgentOrb extends StatelessWidget {
  const _AgentOrb();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Open Atlas Gym Buddy',
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          final lift = 2 * (1 - (value - 0.5).abs() * 2);
          return Transform.translate(offset: Offset(0, -lift), child: child);
        },
        child: ClipOval(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              width: _AtlasAgentLauncherState._orbSize,
              height: _AtlasAgentLauncherState._orbSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const _PlateBuddyFace(size: 62),
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
                    _BuddyHeader(screen: widget.initialScreen),
                    _BuddyContextStrip(screen: widget.initialScreen),
                    _BuddySuggestionRail(
                      suggestions: _suggestions,
                      sending: _sending,
                      onTap: _send,
                    ),
                    const SizedBox(height: 12),
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

class _BuddyHeader extends StatelessWidget {
  const _BuddyHeader({required this.screen});

  final String screen;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isDark
                    ? [
                      Colors.white.withValues(alpha: 0.08),
                      Colors.white.withValues(alpha: 0.025),
                    ]
                    : [
                      Colors.white.withValues(alpha: 0.94),
                      AtlasColors.accentSoft.withValues(alpha: 0.48),
                    ],
          ),
          border: Border.all(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.white.withValues(alpha: 0.72),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.06),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.62),
                ),
              ),
              child: const _PlateBuddyFace(size: 56),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Atlas Buddy',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(height: 1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AtlasColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Your gym buddy for $screen',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AtlasColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.graphic_eq_rounded, color: AtlasColors.accent),
          ],
        ),
      ),
    );
  }
}

class _BuddyContextStrip extends StatelessWidget {
  const _BuddyContextStrip({required this.screen});

  final String screen;

  @override
  Widget build(BuildContext context) {
    final chips = [
      (Icons.visibility_rounded, 'Reads logs'),
      (Icons.fitness_center_rounded, screen),
      (Icons.bolt_rounded, 'Fast advice'),
    ];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = chips[index];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AtlasColors.ink.withValues(alpha: 0.055),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AtlasColors.hairline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(chip.$1, size: 14, color: AtlasColors.accent),
                const SizedBox(width: 6),
                Text(chip.$2, style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BuddySuggestionRail extends StatelessWidget {
  const _BuddySuggestionRail({
    required this.suggestions,
    required this.sending,
    required this.onTap,
  });

  final List<String> suggestions;
  final bool sending;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(22, 10, 22, 0),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return AtlasBuddyPrompt(
            label: suggestion,
            enabled: !sending,
            isDark: isDark,
            onTap: () => onTap(suggestion),
          );
        },
      ),
    );
  }
}

class AtlasBuddyPrompt extends StatelessWidget {
  const AtlasBuddyPrompt({
    required this.label,
    required this.enabled,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.52,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color:
                isDark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.09)
                      : AtlasColors.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                size: 15,
                color: AtlasColors.accent,
              ),
              const SizedBox(width: 7),
              Text(label, style: Theme.of(context).textTheme.labelLarge),
            ],
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
    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.sizeOf(context).width * 0.76,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AtlasColors.accent, AtlasColors.accentDeep],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(22),
              topRight: Radius.circular(22),
              bottomLeft: Radius.circular(22),
              bottomRight: Radius.circular(7),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.accent.withValues(alpha: 0.18),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Text(
            message.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              height: 1.42,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            border: Border.all(color: AtlasColors.hairline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const _PlateBuddyFace(size: 30),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.fromLTRB(15, 12, 15, 14),
            decoration: BoxDecoration(
              color:
                  isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : Colors.white.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                color:
                    isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.white.withValues(alpha: 0.72),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.055),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Buddy note',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AtlasColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.bolt_rounded,
                      size: 14,
                      color: AtlasColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Text(
                  message.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.48,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color:
            isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.white.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color:
              isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.76),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AtlasColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AtlasColors.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !sending,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: sending ? null : onSend,
              decoration: const InputDecoration(
                hintText: 'Talk training, food, recovery...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: sending ? null : () => onSend(null),
            style: FilledButton.styleFrom(
              minimumSize: const Size(48, 48),
              padding: EdgeInsets.zero,
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
      ),
    );
  }
}

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
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A3D43), Color(0xFF0C0D10), Color(0xFF1C2028)],
            stops: [0, 0.55, 1],
          ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius * 0.98, platePaint);

    final outerRim =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.08
          ..shader = const LinearGradient(
            colors: [Color(0xFF6B7280), Color(0xFF111827)],
          ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius * 0.91, outerRim);

    final innerRing =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.08
          ..color = const Color(0xFF2F343D);
    canvas.drawCircle(center, radius * 0.32, innerRing);

    final hole =
        Paint()
          ..shader = const RadialGradient(
            center: Alignment.topLeft,
            colors: [Color(0xFFF8FAFC), Color(0xFF9CA3AF), Color(0xFF111827)],
            stops: [0, 0.58, 1],
          ).createShader(Offset.zero & size);
    canvas.drawCircle(center, radius * 0.2, hole);

    final gripPaint =
        Paint()
          ..color = Colors.black.withValues(alpha: 0.34)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = radius * 0.2;
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

    final labelPainter = TextPainter(
      text: TextSpan(
        text: '25 LB',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.82),
          fontSize: radius * 0.24,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(
      canvas,
      Offset(center.dx - labelPainter.width / 2, size.height * 0.2),
    );

    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.39, size.height * 0.43),
      radius * 0.065,
      eyePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.61, size.height * 0.43),
      radius * 0.065,
      eyePaint,
    );

    final mouth =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.07
          ..strokeCap = StrokeCap.round
          ..color = Colors.white;
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
