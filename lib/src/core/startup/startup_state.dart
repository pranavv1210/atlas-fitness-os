import '../../features/profile/domain/models/user_profile.dart';
import '../errors/app_failure.dart';

enum StartupStep {
  splash,
  initializingServices,
  checkingAuthentication,
  restoringSession,
  loadingProfile,
  authenticated,
  unauthenticated,
  failure,
}

class StartupState {
  const StartupState._({
    required this.step,
    required this.message,
    this.profile,
    this.failure,
  });

  const StartupState.splash()
    : this._(step: StartupStep.splash, message: 'Starting Atlas');

  const StartupState.loading(StartupStep step, String message)
    : this._(step: step, message: message);

  const StartupState.authenticated(UserProfile profile)
    : this._(
        step: StartupStep.authenticated,
        message: 'Atlas is ready',
        profile: profile,
      );

  const StartupState.unauthenticated()
    : this._(step: StartupStep.unauthenticated, message: 'Sign in to continue');

  const StartupState.failure(AppFailure failure)
    : this._(
        step: StartupStep.failure,
        message: 'Atlas needs attention',
        failure: failure,
      );

  final StartupStep step;
  final String message;
  final UserProfile? profile;
  final AppFailure? failure;
}
