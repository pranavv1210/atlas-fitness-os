import 'package:flutter/material.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/widgets/atlas_logo.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({
    required this.onGoogleSignIn,
    this.failure,
    this.isBusy = false,
    super.key,
  });

  final VoidCallback onGoogleSignIn;
  final AppFailure? failure;
  final bool isBusy;

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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                const AtlasLogo(size: 116),
                const SizedBox(height: 18),
                Text('Atlas', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 10),
                Text(
                  'Your Personal Fitness Operating System',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Login with Google so each person keeps separate workouts, goals, and progress.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (failure != null) ...[
                  const SizedBox(height: 18),
                  _AuthFailureBanner(failure: failure!),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: isBusy ? null : onGoogleSignIn,
                  icon:
                      isBusy
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.login_rounded),
                  label: Text(isBusy ? 'Signing In' : 'Login with Google'),
                ),
                const SizedBox(height: 12),
                Text(
                  'Google Sign-In only. No social features, ads, or public profile.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFailureBanner extends StatelessWidget {
  const _AuthFailureBanner({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AtlasColors.roseSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AtlasColors.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AtlasColors.rose),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              failure.message,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
