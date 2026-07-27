import 'dart:async';

import '../../features/auth/domain/models/auth_session.dart';
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

    try {
      await _withTimeout(
        'local services initialization',
        _dependencies.initializeLocalServices(),
        const Duration(seconds: 5),
      );
    } on Object catch (error, stackTrace) {
      _dependencies.logger.error(
        'Startup failed while initializing local services',
        error: error,
        stackTrace: stackTrace,
      );
      return const StartupState.failure(
        AppFailure(
          kind: AppFailureKind.unknown,
          message: 'Atlas could not initialize local services.',
        ),
      );
    }

    final supabaseResult = await _withTimeout(
      'Supabase initialization',
      _dependencies.supabaseBootstrap.initialize(),
      const Duration(seconds: 12),
    );
    if (supabaseResult case Failure failure) {
      return StartupState.failure(failure.failure);
    }
    _dependencies.registerSupabaseClient((supabaseResult as Success).value);

    final authInit = await _withTimeout(
      'auth initialization',
      _dependencies.authRepository.initialize(),
      const Duration(seconds: 8),
    );
    if (authInit case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    final networkStatus = await _withTimeout(
      'connectivity check',
      _dependencies.connectivityService.currentStatus(),
      const Duration(seconds: 3),
      fallback: NetworkStatus.online,
    );
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
    final sessionResult = await _withTimeout(
      'session restore',
      _dependencies.authRepository.restoreSession(),
      const Duration(seconds: 12),
      fallback: const Success(null),
    );
    if (sessionResult case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    final session = (sessionResult as Success).value;
    if (session == null) {
      return const StartupState.unauthenticated();
    }

    if (_dependencies.preferences.biometricEnabled) {
      final unlocked = await _withTimeout(
        'biometric authentication',
        _dependencies.biometricService.authenticate(),
        const Duration(seconds: 30),
        fallback: false,
      );
      if (!unlocked) {
        return const StartupState.failure(
          AppFailure(
            kind: AppFailureKind.permission,
            message: 'Atlas is locked. Use biometrics or device unlock.',
          ),
        );
      }
    }

    _requestNotificationPermissionInBackground();
    return _loadProfile(onStateChanged, session);
  }

  Future<StartupState> signInWithGoogle({
    required void Function(StartupState state) onStateChanged,
  }) async {
    final networkStatus = await _withTimeout(
      'connectivity check',
      _dependencies.connectivityService.currentStatus(),
      const Duration(seconds: 3),
      fallback: NetworkStatus.online,
    );
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
    final signIn = await _withTimeout(
      'Google sign-in',
      _dependencies.authRepository.signInWithGoogle(),
      const Duration(seconds: 60),
    );
    if (signIn case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    final session = (signIn as Success).value;
    _requestNotificationPermissionInBackground();
    return _loadProfile(onStateChanged, session);
  }

  Future<StartupState> signOut() async {
    final result = await _withTimeout(
      'sign out',
      _dependencies.authRepository.signOut(),
      const Duration(seconds: 10),
    );
    if (result case Failure failure) {
      return StartupState.failure(failure.failure);
    }

    return const StartupState.unauthenticated();
  }

  Future<StartupState> _loadProfile(
    void Function(StartupState state) onStateChanged,
    AuthSession session,
  ) async {
    onStateChanged(
      const StartupState.loading(
        StartupStep.loadingProfile,
        'Loading initial profile',
      ),
    );
    final profileResult = await _withTimeout(
      'profile loading',
      _dependencies.profileRepository.loadInitialProfile(),
      const Duration(seconds: 12),
      fallback: Success(_profileFromSession(session)),
    );
    if (profileResult case Failure<UserProfile> failure) {
      return StartupState.failure(failure.failure);
    }

    return StartupState.authenticated(
      (profileResult as Success<UserProfile>).value,
    );
  }

  void _requestNotificationPermissionInBackground() {
    unawaited(
      _requestNotificationPermissionIfNeeded()
          .timeout(const Duration(seconds: 8))
          .catchError((Object error, StackTrace stackTrace) {
            _dependencies.logger.warning(
              'Hydration notification startup scheduling was skipped',
              error: error,
              stackTrace: stackTrace,
            );
          }),
    );
  }

  Future<void> _requestNotificationPermissionIfNeeded() async {
    final preferences = _dependencies.preferences;
    if (preferences.notificationPrompted) {
      if (preferences.notificationEnabled) {
        await _dependencies.notificationService.scheduleAtlasReminders(
          hydrationIntervalMinutes: preferences.hydrationIntervalMinutes,
        );
      }
      return;
    }

    final granted = await _dependencies.notificationService.requestPermission();
    await preferences.setNotificationPrompted();
    await preferences.setNotificationEnabled(granted);
    if (granted) {
      await _dependencies.notificationService.scheduleAtlasReminders(
        hydrationIntervalMinutes: preferences.hydrationIntervalMinutes,
      );
    }
  }

  Future<T> _withTimeout<T>(
    String label,
    Future<T> future,
    Duration timeout, {
    T? fallback,
  }) {
    return future.timeout(
      timeout,
      onTimeout: () {
        _dependencies.logger.warning('$label timed out during startup');
        if (fallback != null) {
          return fallback;
        }
        throw TimeoutException(label, timeout);
      },
    );
  }

  UserProfile _profileFromSession(AuthSession session) {
    final user = session.user;
    return UserProfile(
      userId: user.id,
      email: user.email,
      displayName:
          user.displayName?.trim().isNotEmpty == true
              ? user.displayName!.trim()
              : user.email.split('@').first,
      avatarUrl: user.avatarUrl,
    );
  }
}
