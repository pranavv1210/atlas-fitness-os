import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/result.dart';
import '../../../../core/logging/app_logger.dart';

class GoogleAuthTokens {
  const GoogleAuthTokens({required this.idToken});

  final String idToken;
}

abstract interface class GoogleAuthRemoteDataSource {
  Future<Result<void>> initialize();

  Future<Result<GoogleAuthTokens?>> attemptLightweightSignIn();

  Future<Result<GoogleAuthTokens>> signIn();

  Future<Result<void>> signOut();
}

class GoogleSignInRemoteDataSource implements GoogleAuthRemoteDataSource {
  GoogleSignInRemoteDataSource(this._logger);

  final AppLogger _logger;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _initialized = false;

  @override
  Future<Result<void>> initialize() async {
    if (_initialized) {
      return const Success(null);
    }

    if (!AppConfig.hasGoogleConfig) {
      return const Failure(
        AppFailure(
          kind: AppFailureKind.configuration,
          message:
              'Missing GOOGLE_WEB_CLIENT_ID. Provide it with --dart-define.',
        ),
      );
    }

    try {
      await _googleSignIn.initialize(
        clientId:
            AppConfig.googleAndroidClientId.isEmpty
                ? null
                : AppConfig.googleAndroidClientId,
        serverClientId: AppConfig.googleWebClientId,
      );
      _initialized = true;
      _logger.info('Google Sign-In initialized');
      return const Success(null);
    } catch (error, stackTrace) {
      _logger.error(
        'Google Sign-In initialization failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Failure(
        AppFailure(
          kind: AppFailureKind.configuration,
          message: 'Atlas could not initialize Google Sign-In.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<GoogleAuthTokens?>> attemptLightweightSignIn() async {
    final initialized = await initialize();
    if (initialized case Failure<void> failure) {
      return Failure(failure.failure);
    }

    try {
      final future = _googleSignIn.attemptLightweightAuthentication();
      final account = await future;
      if (account == null) {
        return const Success(null);
      }

      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Failure(
          AppFailure(
            kind: AppFailureKind.authentication,
            message: 'Google did not return an ID token.',
          ),
        );
      }

      return Success(GoogleAuthTokens(idToken: idToken));
    } catch (error, stackTrace) {
      _logger.warning(
        'Lightweight Google Sign-In failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas could not restore Google authentication.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<GoogleAuthTokens>> signIn() async {
    final initialized = await initialize();
    if (initialized case Failure<void> failure) {
      return Failure(failure.failure);
    }

    try {
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        return const Failure(
          AppFailure(
            kind: AppFailureKind.authentication,
            message: 'Google did not return an ID token.',
          ),
        );
      }

      return Success(GoogleAuthTokens(idToken: idToken));
    } on GoogleSignInException catch (error, stackTrace) {
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Google Sign-In was not completed.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      _logger.error(
        'Google Sign-In failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas could not sign in with Google.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _googleSignIn.signOut();
      return const Success(null);
    } catch (error, stackTrace) {
      _logger.warning(
        'Google Sign-Out failed',
        error: error,
        stackTrace: stackTrace,
      );
      return Failure(
        AppFailure(
          kind: AppFailureKind.authentication,
          message: 'Atlas could not sign out of Google.',
          cause: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
