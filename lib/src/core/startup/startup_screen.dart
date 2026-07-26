import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/navigation/atlas_shell.dart';
import '../../app/theme/atlas_colors.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../di/app_scope.dart';
import '../errors/app_failure.dart';
import '../widgets/atlas_logo.dart';
import 'startup_controller.dart';
import 'startup_state.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  late final StartupController _controller;
  StartupState _state = const StartupState.splash();

  bool get _isBusy =>
      _state.step != StartupStep.authenticated &&
      _state.step != StartupStep.unauthenticated &&
      _state.step != StartupStep.failure;

  @override
  void initState() {
    super.initState();
    _controller = StartupController(AppScope.read(context));
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final started = DateTime.now();
    final result = await _controller.start(onStateChanged: _setState);
    final elapsed = DateTime.now().difference(started);
    const minimumSplash = Duration(milliseconds: 1900);
    if (elapsed < minimumSplash) {
      await Future<void>.delayed(minimumSplash - elapsed);
    }
    _setState(result);
  }

  Future<void> _signIn() async {
    final result = await _controller.signInWithGoogle(
      onStateChanged: _setState,
    );
    _setState(result);
  }

  Future<void> _signOut() async {
    final result = await _controller.signOut();
    _setState(result);
  }

  void _setState(StartupState state) {
    if (!mounted) {
      return;
    }
    setState(() => _state = state);
  }

  @override
  Widget build(BuildContext context) {
    final profile = _state.profile;
    if (_state.step == StartupStep.authenticated && profile != null) {
      return AtlasShell(profile: profile, onSignOut: _signOut);
    }

    if (_state.step == StartupStep.unauthenticated) {
      return AuthScreen(onGoogleSignIn: _signIn);
    }

    if (_state.step == StartupStep.failure) {
      final failure = _state.failure!;
      if (failure.kind == AppFailureKind.authentication ||
          failure.kind == AppFailureKind.permission) {
        return AuthScreen(
          onGoogleSignIn: _signIn,
          failure: failure,
          isBusy: _isBusy,
        );
      }

      return _StartupFailureView(failure: failure, onRetry: _start);
    }

    return _SplashView(message: _state.message);
  }
}

class _SplashView extends StatefulWidget {
  const _SplashView({required this.message});

  final String message;

  @override
  State<_SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<_SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070D),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final pulse = 0.96 + math.sin(_controller.value * math.pi) * 0.06;
          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _SplashPainter(_controller.value)),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: pulse,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AtlasColors.accent.withValues(
                                  alpha: 0.42,
                                ),
                                blurRadius: 62,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: const AtlasLogo(size: 132),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Atlas',
                        style: Theme.of(
                          context,
                        ).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Personal Fitness Operating System',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.74),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SplashPainter extends CustomPainter {
  const _SplashPainter(this.phase);

  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final gradientPaint =
        Paint()
          ..shader = RadialGradient(
            center: Alignment(0.2 * math.sin(phase * math.pi * 2), -0.25),
            radius: 0.9,
            colors: [
              AtlasColors.accent.withValues(alpha: 0.38),
              AtlasColors.success.withValues(alpha: 0.12),
              Colors.transparent,
            ],
          ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, gradientPaint);

    final particlePaint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (var index = 0; index < 42; index++) {
      final x = (math.sin(index * 11.7 + phase * 2) * 0.5 + 0.5) * size.width;
      final y = (math.cos(index * 8.3 + phase * 3) * 0.5 + 0.5) * size.height;
      canvas.drawCircle(Offset(x, y), 0.8 + (index % 4) * 0.35, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashPainter oldDelegate) {
    return oldDelegate.phase != phase;
  }
}

class _StartupFailureView extends StatelessWidget {
  const _StartupFailureView({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Icon(
                Icons.cloud_off_outlined,
                size: 42,
                color: AtlasColors.inkMuted,
              ),
              const SizedBox(height: 18),
              Text(
                'Atlas could not start',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                failure.message,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              FilledButton(
                onPressed: failure.canRetry ? onRetry : null,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
