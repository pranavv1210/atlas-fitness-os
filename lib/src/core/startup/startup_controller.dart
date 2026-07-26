import '../../features/profile/domain/models/user_profile.dart';
import '../di/app_dependencies.dart';
import '../errors/app_failure.dart';
import '../errors/result.dart';
import '../network/connectivity_service.dart';
import 'startup_state.dart';

class StartupController {
  StartupController(this._dependencies);

  final AppDependencies _dependencies;

  Future<StartupState> start({
    required void Function(StartupState state) onStateChanged,
  }) async {
    onStateChanged(
      const StartupState.loading(
        StartupStep.initializingServices,
        'Initializing services',
      ),
    );

    await _dependencies.initializeLocalServices();

    final supabaseResult = await _dependencies.supabaseBootstrap.initialize();
    if (supabaseResult case Failure failure) {
      return StartupState.failure(failure.failure);
    }
    _dependencies.registerSupabaseClient((supabaseResult as Success).value);

    final authInit = await _dependencies.authRepository.initialize();
    if (authInit case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    final networkStatus =
        await _dependencies.connectivityService.currentStatus();
    if (networkStatus == NetworkStatus.offline) {
      _dependencies.logger.warning(
        'Device is offline during startup; attempting local session restore',
      );
    }

    onStateChanged(
      const StartupState.loading(
        StartupStep.checkingAuthentication,
        'Checking authentication',
      ),
    );

    onStateChanged(
      const StartupState.loading(
        StartupStep.restoringSession,
        'Restoring secure session',
      ),
    );
    final sessionResult = await _dependencies.authRepository.restoreSession();
    if (sessionResult case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    final session = (sessionResult as Success).value;
    if (session == null) {
      return const StartupState.unauthenticated();
    }

    if (_dependencies.preferences.biometricEnabled) {
      final unlocked = await _dependencies.biometricService.authenticate();
      if (!unlocked) {
        return const StartupState.failure(
          AppFailure(
            kind: AppFailureKind.permission,
            message: 'Atlas is locked. Use biometrics or device unlock.',
          ),
        );
      }
    }

    await _requestNotificationPermissionIfNeeded();
    return _loadProfile(onStateChanged);
  }

  Future<StartupState> signInWithGoogle({
    required void Function(StartupState state) onStateChanged,
  }) async {
    final networkStatus =
        await _dependencies.connectivityService.currentStatus();
    if (networkStatus == NetworkStatus.offline) {
      return const StartupState.failure(
        AppFailure(
          kind: AppFailureKind.offline,
          message: 'Atlas needs a connection to sign in with Google.',
        ),
      );
    }

    onStateChanged(
      const StartupState.loading(
        StartupStep.checkingAuthentication,
        'Opening Google Sign-In',
      ),
    );
    final signIn = await _dependencies.authRepository.signInWithGoogle();
    if (signIn case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    await _requestNotificationPermissionIfNeeded();
    return _loadProfile(onStateChanged);
  }

  Future<StartupState> signOut() async {
    final result = await _dependencies.authRepository.signOut();
    if (result case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    return const StartupState.unauthenticated();
  }

  Future<StartupState> _loadProfile(
    void Function(StartupState state) onStateChanged,
  ) async {
    onStateChanged(
      const StartupState.loading(
        StartupStep.loadingProfile,
        'Loading initial profile',
      ),
    );
    final profileResult =
        await _dependencies.profileRepository.loadInitialProfile();
    if (profileResult case Failure<UserProfile> failure) {
      return StartupState.failure(failure.failure);
    }

    return StartupState.authenticated(
      (profileResult as Success<UserProfile>).value,
    );
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    final preferences = _dependencies.preferences;
    if (preferences.notificationPrompted) {
      if (preferences.notificationEnabled) {
        await _dependencies.notificationService.scheduleHydrationNudges(
          intervalMinutes: preferences.hydrationIntervalMinutes,
        );
      }
      return;
    }

    final granted = await _dependencies.notificationService.requestPermission();
    await preferences.setNotificationPrompted();
    await preferences.setNotificationEnabled(granted);
    if (granted) {
      await _dependencies.notificationService.scheduleHydrationNudges(
        intervalMinutes: preferences.hydrationIntervalMinutes,
      );
    }
  }
}
