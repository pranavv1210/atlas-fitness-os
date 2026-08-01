import 'dart:ui';

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
                  gradient: const RadialGradient(
                    center: Alignment.topLeft,
                    radius: 1.18,
                    colors: [
                      Colors.white,
                      AtlasColors.success,
                      AtlasColors.accent,
                      AtlasColors.accentDeep,
                    ],
                    stops: [0, 0.18, 0.62, 1],
                  ),
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      color: Colors.white.withValues(alpha: 0.96),
                      size: 26,
                    ),
                    Positioned(
                      right: 11,
                      top: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(99),
                        ),
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
                color:
                    isDark
                        ? const Color(0xEE131620)
                        : Colors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(34),
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.62),
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
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const RadialGradient(
                                center: Alignment.topLeft,
                                colors: [
                                  Colors.white,
                                  AtlasColors.success,
                                  AtlasColors.accent,
                                  AtlasColors.accentDeep,
                                ],
                                stops: [0, 0.2, 0.68, 1],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AtlasColors.accent.withValues(
                                    alpha: 0.22,
                                  ),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.fitness_center_rounded,
                              color: Colors.white,
                            ),
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
                            avatar: const Icon(
                              Icons.fitness_center_rounded,
                              size: 16,
                            ),
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
                  : Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.9),
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
