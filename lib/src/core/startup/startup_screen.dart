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
    final result = await _controller.start(onStateChanged: _setState);
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

class _SplashView extends StatelessWidget {
  const _SplashView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFBFAF7), AtlasColors.background],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AtlasLogo(size: 122),
                const SizedBox(height: 18),
                Text('Atlas', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 14),
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 28),
                const SizedBox.square(
                  dimension: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
