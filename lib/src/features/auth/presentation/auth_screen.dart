import 'dart:ui';

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
            colors: [Color(0xFFFFFFFF), AtlasColors.background],
          ),
        ),
        child: Stack(
          children: [
            const Positioned.fill(child: _AuthBackground()),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 28),
                children: [
                  const _AuthBrandHeader(),
                  const SizedBox(height: 26),
                  _AuthHeroCard(
                    onGoogleSignIn: onGoogleSignIn,
                    isBusy: isBusy,
                    failure: failure,
                  ),
                  const SizedBox(height: 18),
                  const _AuthSecurityGrid(),
                  const SizedBox(height: 18),
                  _LegalNotice(onShowTerms: () => _showTermsSheet(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthBackground extends StatelessWidget {
  const _AuthBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _AuthBackgroundPainter());
  }
}

class _AuthBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint =
        Paint()
          ..color = AtlasColors.accentSoft.withValues(alpha: 0.82)
          ..style = PaintingStyle.fill;
    final greenPaint =
        Paint()
          ..color = AtlasColors.successSoft.withValues(alpha: 0.52)
          ..style = PaintingStyle.fill;
    final path =
        Path()
          ..moveTo(0, size.height * 0.18)
          ..cubicTo(
            size.width * 0.28,
            size.height * 0.08,
            size.width * 0.58,
            size.height * 0.33,
            size.width,
            size.height * 0.18,
          )
          ..lineTo(size.width, size.height * 0.44)
          ..cubicTo(
            size.width * 0.66,
            size.height * 0.54,
            size.width * 0.28,
            size.height * 0.36,
            0,
            size.height * 0.5,
          )
          ..close();
    canvas.drawPath(path, bluePaint);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.72),
      size.width * 0.36,
      greenPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AuthBrandHeader extends StatelessWidget {
  const _AuthBrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AtlasLogo(size: 44),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Atlas', style: Theme.of(context).textTheme.titleLarge),
              Text(
                'Personal Fitness Operating System',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AtlasColors.inkMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AtlasColors.successSoft,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AtlasColors.hairline),
          ),
          child: Text(
            'Secure',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AtlasColors.success,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _AuthHeroCard extends StatelessWidget {
  const _AuthHeroCard({
    required this.onGoogleSignIn,
    required this.isBusy,
    required this.failure,
  });

  final VoidCallback onGoogleSignIn;
  final bool isBusy;
  final AppFailure? failure;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(34),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.86),
            borderRadius: BorderRadius.circular(34),
            border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.ink.withValues(alpha: 0.1),
                blurRadius: 36,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [AtlasColors.success, AtlasColors.accent],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AtlasColors.accent.withValues(alpha: 0.22),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Start clean. Keep every account separate.',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  height: 0.96,
                  letterSpacing: -1.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Sign in with Google to create your private Atlas workspace. Your workouts, goals, hydration, weight, reports, and Buddy context stay tied to your account only.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: AtlasColors.inkMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (failure != null) ...[
                const SizedBox(height: 16),
                _AuthFailureBanner(failure: failure!),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : onGoogleSignIn,
                  icon:
                      isBusy
                          ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.g_mobiledata_rounded, size: 28),
                  label: Text(
                    isBusy ? 'Signing in securely' : 'Continue with Google',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: AtlasColors.inkMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No public profile, no social feed, no mixed accounts.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AtlasColors.inkMuted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthSecurityGrid extends StatelessWidget {
  const _AuthSecurityGrid();

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        Icons.verified_user_rounded,
        'Google Auth',
        'Identity is handled by Google and Supabase.',
      ),
      (
        Icons.person_pin_circle_rounded,
        'Account scoped',
        'Logs are saved with your user ID only.',
      ),
      (
        Icons.security_rounded,
        'RLS protected',
        'Supabase policies restrict private rows to the owner.',
      ),
      (
        Icons.fingerprint_rounded,
        'Biometric lock',
        'Optional device biometrics add local protection.',
      ),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.96,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.78),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AtlasColors.hairline),
            boxShadow: [
              BoxShadow(
                color: AtlasColors.ink.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AtlasColors.accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(item.$1, color: AtlasColors.accent, size: 20),
              ),
              const Spacer(),
              Text(item.$2, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                item.$3,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AtlasColors.inkMuted,
                  height: 1.32,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice({required this.onShowTerms});

  final VoidCallback onShowTerms;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'By continuing, you agree to use Atlas for personal fitness tracking. Atlas is not medical advice. Keep your Google account and device secure.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AtlasColors.inkMuted,
            height: 1.35,
          ),
        ),
        TextButton(
          onPressed: onShowTerms,
          child: const Text('Terms, privacy, and security details'),
        ),
      ],
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
        borderRadius: BorderRadius.circular(18),
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

void _showTermsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.74,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (context, controller) {
              return ListView(
                controller: controller,
                children: [
                  Text(
                    'Atlas Terms and Privacy',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const _TermsBlock(
                    title: 'What you are signing up for',
                    body:
                        'Atlas stores your fitness logs so you can track workouts, exercises, sets, reps, weight, hydration, goals, cardio, sports, progress, and reports across devices.',
                  ),
                  const _TermsBlock(
                    title: 'Account separation',
                    body:
                        'Your logs are tied to your Google/Supabase account. Another user signing in with a different Google account gets their own workspace and cannot see your private rows.',
                  ),
                  const _TermsBlock(
                    title: 'Security model',
                    body:
                        'Atlas uses authenticated Supabase sessions, user_id scoped writes, row level security policies, and optional biometric lock. Keep your device, Google account, and screen lock protected.',
                  ),
                  const _TermsBlock(
                    title: 'Atlas Buddy',
                    body:
                        'Atlas Buddy reads your saved Atlas logs only to answer your questions and give training context. It should not be treated as medical, injury, or emergency advice.',
                  ),
                  const _TermsBlock(
                    title: 'Health disclaimer',
                    body:
                        'Atlas is a fitness tracking tool. Consult a qualified professional before starting intense training, changing diet, or training through pain or injury.',
                  ),
                  const _TermsBlock(
                    title: 'Your responsibility',
                    body:
                        'You are responsible for entering accurate data, training safely, and using the app in a lawful way. Do not share your account with other people.',
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

class _TermsBlock extends StatelessWidget {
  const _TermsBlock({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: AtlasColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
